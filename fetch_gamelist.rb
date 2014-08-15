# encoding: utf-8
require 'open-uri'
require 'nokogiri'
require 'nkf'
require 'active_record'

# bbs.db に接続
ActiveRecord::Base.establish_connection(
    "adapter" => "sqlite3",
    "database" => "./mobage.db"
)

class Game < ActiveRecord::Base
end

Game.all.delete_all
# p Game.all


# 最初のページ
$baseurl = 'http://www.mbga.jp/'
#url = '_game_categ_list?c=2000&o='
#'_game_newly_list'

def loadDatas(loadUrl, genre)
    
    charset = nil
    p loadUrl
    
    html = open(loadUrl) do |f|
        charset = f.charset
        f.read
    end
    
    
    doc = Nokogiri::HTML.parse(html, nil, charset)
    
    doc.xpath('//a[@class="listGameInner"]').each do |node|
        
        p "================================="
        
        
        gameUrl = node.attribute('href').value
        gameUrl = gameUrl.slice(1..-1)
        rUrl = $baseurl + gameUrl
        p rUrl
        
        rTitleRaw = ""
        rTitle = ""
        rTitleDigest = ""
        rCatchCopy = ""
        rIOS = 0
        rAndroid = 0
        rMobile = 0
        rThumbnailUrl = ""
        rDescription = ""
        rSAP = ""
        rImageUrl = ""
        node.xpath('.//h2[@class="listGameTitle"]').each do |childNode|
            rTitleRaw = childNode.children[0].text
            rTitle = NKF::nkf('-wm0 ', childNode.children[0].text)
            rTitleDigest = Digest::MD5.new.update(rTitle).to_s
        end
        node.xpath('.//p[@class="listGameDesc"]').each do |childNode|
            rCatchCopy = NKF::nkf('-wm0 ', childNode.children[0].text)
        end
        node.xpath('.//li[@class="modelI"]').each do |childNode|
            rIOS = 1
        end
        node.xpath('.//li[@class="modelA"]').each do |childNode|
            rAndroid = 1
        end
        node.xpath('.//li[@class="modelF"]').each do |childNode|
            rMobile = 1
        end
        node.xpath('.//div[@class="listGameImage"]').each do |childNode|
            rThumbnailUrl = childNode.children[0].attribute('src').value
        end
        
    
        gameHTML = open(rUrl) do |f|
            f.read
        end
    
        gameDoc = Nokogiri::HTML.parse(gameHTML, nil, charset)
        
        gameTitle = ""
        gameDoc.xpath('//h1[@class="gameTitle"]').each do |gameNode|
            gameTitle = gameNode.children[0].text
        end
        if (gameTitle == "")
            p "game_intro なさそう"
        end
    #     gameDoc.xpath('//p[@class="gameDesc"]').each do |gameNode|
    #         rDescription = gameNode.children[0].text
    #     end
        gameDoc.xpath('//p[@class="gameIntroCaption"]').each do |gameNode|
            rDescription = NKF::nkf('-wm0 ', gameNode.children[0].text)
        end
        gameDoc.xpath('//span[@class="gameIntroCompany"]').each do |gameNode|
            rSAP = gameNode.children[0].text
        end
    #     gameDoc.xpath('//div[@class="gameIntroImage"]').each do |gameNode|
    #         p gameNode.children[0].attribute('src').value
    #     end
        gameDoc.xpath('//div[@class="gameImage"]').each do |gameNode|
            rImageUrl = gameNode.children[0].attribute('src').value
        end
    #     gameDoc.xpath('//p[@class="gameStartUrl"]').each do |gameNode|
    #         p gameNode.children[0].text
    #     end
    #     gameDoc.xpath('//li[# @class="ios supported"]').each do |gameNode|
    #         p gameNode.children[0].text
    #     end
    #     gameDoc.xpath('//li[@class="android supported"]').each do |gameNode|
    #         p gameNode.children[0].text
    #     end
    #     gameDoc.xpath('//li[@class="mobile supported"]').each do |gameNode|
    #         p gameNode.children[0].text
    #     end
        
        p rUrl;
        p rTitle;
        p rTitleDigest;
        p rTitleRaw;
        p rCatchCopy;
        p rDescription;
        p rSAP;
        p rImageUrl;
        p rThumbnailUrl;
        p "IOS " + rIOS.to_s;
        p "Android " + rAndroid.to_s;
        p "Mobile " + rMobile.to_s;
        
        game = Game.find_by(:title_digest => rTitleDigest)
        
        if game
            rGenre = game.genre + " " + genre
            game.update_attribute(:genre, rGenre)
        else
            game = Game.new(:title_raw => rTitleRaw, :title => rTitle, :title_digest => rTitleDigest, :catch_copy => rCatchCopy, :description => rDescription, :url => rUrl, :genre => genre, :tags => "", :sap => rSAP, :imageUrl => rImageUrl, :thumbnailUrl => rThumbnailUrl, :ios => rIOS, :android => rAndroid, :mobile => rMobile)
            game.save
        end
        
        
    end
    
    doc.xpath('//a[@class="pagerNext"]').each do |node|
        nextUrl = node.attribute('href').value
        nextUrl = nextUrl.slice(1..-1)
        loadDatas($baseurl + nextUrl, genre)
    end
    
end

loadDatas($baseurl + '_game_categ_list?c=2000&o=', 'rpg')
loadDatas($baseurl + '_game_categ_list?c=21000&o=', 'romance')
loadDatas($baseurl + '_game_categ_list?c=13000&o=', 'grow')
loadDatas($baseurl + '_game_categ_list?c=18000&o=', 'board')
loadDatas($baseurl + '_game_categ_list?c=20000&o=', 'gambling')
loadDatas($baseurl + '_game_categ_list?c=9000&o=', 'action')
loadDatas($baseurl + '_game_categ_list?c=5000&o=', 'puzzle')
loadDatas($baseurl + '_game_categ_list?c=4000&o=', 'sports')
loadDatas($baseurl + '_game_categ_list?c=14000&o=', 'adventure')
loadDatas($baseurl + '_game_categ_list?c=12000&o=', 'education')
loadDatas($baseurl + '_game_categ_list?c=22000&o=', 'others')


# Additional datas

title = "ガンダムロワイヤル"
url = "http://rx.sp.mbga.jp/_gndm_top"
catchCopy = "レア機体をコレクションしよう！目指せ！最強パイロット！"
sap = "提供：株式会社バンダイナムコゲームス"
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000015.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "rpg", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save

title = "ガンダムカードコレクション"
url = "http://www.mbga.jp/lp/game/gcc/"
catchCopy = "【全シリーズ登場】組み合わせ無限大∞MS×パイロットの最強ユニットを作ろう!!"
sap = "提供：株式会社バンダイナムコゲームス"
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000022.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "rpg", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save

title = "ONE PIECE グランドコレクション"
url = "http://www.mbga.jp/lp/game/onepi/"
catchCopy = "最強の一味をつくろう！"
sap = "提供：株式会社バンダイナムコゲームス"
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000025.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "rpg", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save

title = "FINAL FANTASY BRIGADE -BREAK THE SEAL-"
url = "http://www.mbga.jp/_ffjm_top"
catchCopy = "新たな『RPG』始まる－｢FINAL FANTASY BRIGADE BREAK THE SEAL｣"
sap = "提供：株式会社スクウェア・エニックス、株式会社ディー・エヌ・エー"
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000023.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "rpg", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save

title = "セトルリン"
url = "http://mbga.jp/pc/html/sg_stl/"
catchCopy = "面倒なお世話は不要！不思議な妖精♪ 住み着き妖精セトルリン"
sap = ""
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000006.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "grow", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save

title = "農園ホッコリーナ"
url = "http://mbga.jp/pc/html/sg_fm/"
catchCopy = "素敵な動物たちや不思議な作物で農園をいっぱいにしよう♪"
sap = ""
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000008.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "grow", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save

title = "怪盗ロワイヤル"
url = "http://mbga.jp/pc/html/sg_kt/"
catchCopy = "怪盗団を率いて世界中のお宝を盗み出そう♪"
sap = ""
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000003.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "rpg", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save

title = "アクアスクエア"
# url = "http://mbga.jp/pc/html/sg_as/"
url = "http://sp.mbga.jp/_pf_install?game_id=11000011"
catchCopy = "自分だけの水槽で世界中のお魚を育成♪ あなただけの癒しのアクアリウムを！"
sap = ""
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000011.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "grow", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save

title = "戦国ロワイヤル"
url = "http://sngk.sp.mbga.jp/_sngk_top"
catchCopy = "天下統一!!戦国の覇者となろう!"
sap = ""
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000009.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "rpg", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save

title = "スペースデブリーズ"
url = "http://spc.sp.mbga.jp/_spc_t"
catchCopy = "新感覚！宇宙探索ゲーム★"
sap = ""
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000013.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "rpg", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save

title = "海賊トレジャー"
url = "http://kz.sp.mbga.jp/_kaizoku_top"
catchCopy = "目指せお宝コンプ☆海賊船をカスタマイズして敵をやっつけろ！"
sap = ""
thumbnailUrl = "http://ava-a.sp.mbga.jp/cache/static/i/game/web/top160/11000001.png"
game = Game.new(:title_raw => title, :title => title, :title_digest => Digest::MD5.new.update(title).to_s, :catch_copy => catchCopy, :url => url, :genre => "action", :thumbnailUrl => thumbnailUrl, :sap => sap, :ios => 1, :android => 1, :mobile => 1)
game.save
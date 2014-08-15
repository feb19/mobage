# encoding: utf-8
require 'open-uri'
require 'nokogiri'
require 'nkf'
 
def loadRanking(loadUrl, meta)
    charset = nil
    html = open(loadUrl, 'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53') do |f|
        charset = f.charset
        f.read
    end
    
    p "================================="
    p meta
    doc = Nokogiri::HTML.parse( html, nil, charset )
    
    doc.xpath('//li[@class="line0"]').each do |lineNode|
        p "------"
        lineNode.xpath('.//span[@class="rank"]').each do |node|
            rRank = node.children[1].text
            p rRank
        end
        lineNode.xpath('.//span[@class="caption_l"]').each do |node|
            title = node.children[0].text
            #半角カナを全角カナに置き換え
            rTitle = NKF::nkf('-wm0 ', title)
            p rTitle
        end
        lineNode.xpath('.//span[@class="caption_m"]').each do |node|
            rCaption = node.children[0].text
            #半角カナを全角カナに置き換え
            rCaption = NKF::nkf('-wm0 ', rCaption)
            p rCaption
        end
        lineNode.xpath('.//img[@class="sp-topgame-img"]').each do |node|
            rThumbnail = node.attribute('src').value
            p rThumbnail
        end
    end
end
 
day = Time.now
p day
 
# 総合ランキングの取得
loadRanking("http://sp.mbga.jp/_game_ranking?genre=2000&p=1&sex_type=A", "総合 全体 1-10")
loadRanking("http://sp.mbga.jp/_game_ranking?genre=2000&p=2&sex_type=A", "総合 全体 11-30")
loadRanking("http://sp.mbga.jp/_game_ranking?genre=2000&p=1&sex_type=M", "総合 男性 1-10")
loadRanking("http://sp.mbga.jp/_game_ranking?genre=2000&p=2&sex_type=M", "総合 男性 11-30")
loadRanking("http://sp.mbga.jp/_game_ranking?genre=2000&p=1&sex_type=F", "総合 女性 1-10")
loadRanking("http://sp.mbga.jp/_game_ranking?genre=2000&p=2&sex_type=F", "総合 女性 11-30")
 
# 急上昇ランキングの取得
loadRanking("http://sp.mbga.jp/_game_ranking?genre=1000&p=1&sex_type=A", "急上昇 全体 1-10")
loadRanking("http://sp.mbga.jp/_game_ranking?genre=1000&p=2&sex_type=A", "急上昇 全体 11-30")
loadRanking("http://sp.mbga.jp/_game_ranking?genre=1000&p=1&sex_type=M", "急上昇 男性 1-10")
loadRanking("http://sp.mbga.jp/_game_ranking?genre=1000&p=2&sex_type=M", "急上昇 男性 11-30")
loadRanking("http://sp.mbga.jp/_game_ranking?genre=1000&p=1&sex_type=F", "急上昇 女性 1-10")
loadRanking("http://sp.mbga.jp/_game_ranking?genre=1000&p=2&sex_type=F", "急上昇 女性 11-30")

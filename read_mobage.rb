# encoding: utf-8
require 'active_record'
require 'sinatra'
require 'sinatra/reloader'

# 接続
ActiveRecord::Base.establish_connection(
    "adapter" => "sqlite3",
    "database" => "./mobage.db"
)

class Game < ActiveRecord::Base
end


get '/' do
    ua = request.user_agent
    @sp = 0
    @isAndroid = 0
    @isIOS = 0
    if ["Android"].find {|s| ua.include?(s) }
        @sp = 1
        @isAndroid = 1
    end
    if ["iPhone", "iPad", "iPod"].find {|s| ua.include?(s) }
        @sp = 1
        @isIOS = 1
    end

    # Comment テーブルから id 降順で全部取得
    @games = Game.order("id desc").to_a.shuffle
    @gamesRGP = Game.where(genre: "rpg").to_a.shuffle
    @categories = Game.select(:genre).uniq
    erb :index
end


get '/api/all' do
    # Comment テーブルから id 降順で全部取得
    @games = Game.order("id desc").to_json
end

# @ TrendWord.all

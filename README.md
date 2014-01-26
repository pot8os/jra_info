# JraInfo

CLI application to see horse racing entries and odds provided by [JRA](http://www.jra.go.jp)

## Installation

    $ git clone https://github.com/pot8os/jra_info.git
    $ cd jra_info
    $ bundle install

## Usage

Normal usage is just run the following command.

    $ bundle exec bin/jra_info

Running without arguments is an interactive mode. You can select course.

    $ bundle exec bin/jra_info
    #num| race course
    #---+--------------------
       1| 1月25日(土) 中山
       2| 1月25日(土) 京都
       3| 1月25日(土) 中京
       4| 1月26日(日) 中山
       5| 1月26日(日) 京都
       6| 1月26日(日) 中京
    # press a number to select a race course or 'q' to exit
    #> 

You can see races at Kyoto in Jan 26 after you press 5.

    (snip)
    # press a number to select a race course or 'q' to exit
    #> 5
    #num| races (1月26日(日) 京都)
    #---+--------------------
       1|  1R 10:10 3歳未勝利 1800mダ 16頭
       2|  2R 10:40 3歳未勝利 1200mダ 16頭
       3|  3R 11:10 3歳未勝利 1800mダ 16頭
       4|  4R 11:40 3歳500万下 1400mダ 9頭
       5|  5R 12:30 3歳未勝利 1600m芝 16頭
       6|  6R 13:01 メイクデビュー京都  3歳新馬 1800m芝 15頭
       7|  7R 13:30 4歳以上500万下 1900mダ 9頭
       8|  8R 14:01 4歳以上500万下 1800m芝 11頭
       9|  9R 14:35 北大路特別  4歳上1000下 2000m芝 8頭
      10| 10R 15:10 山科ステークス  4歳上1600下 1200mダ 11頭
      11| 11R 15:45 石清水ステークス  4歳上1600下 1400m芝 16頭
      12| 12R 16:20 4歳以上1000万下 1400mダ 16頭
    # press a number to see entries or 'q' to exit
    #> 

You press 11 if you want to select main race of that.

    # press a number to see entries or 'q' to exit
    #> 11
    #2014年1月26日(日) 1回京都9日
    #11R 石清水ステークス サラ系4歳以上 1600万円以下 (混合) ハンデ1400m 芝・右外 発走15:45
    #------------------------------------------------------------
     1 ラディアーレ       牡6    54.0 畑端省吾        栗東 服部利之      192.9 
     2 コスモアクセス     牝5    52.0 鮫島良太        美浦 田島俊明       58.1 
     3 メイショウヤタロウ 牡6    55.0 藤田伸二        栗東 白井寿昭        6.8 
     4 デンファレ         牝7    53.0 国分恭介        美浦 的場均         54.8 
     5 メイショウハガクレ 牡5    53.0 武幸四郎        栗東 荒川義之       77.2 
     6 オールブランニュー 牝8    51.0 森一馬          栗東 湯窪幸雄      190.6 
     7 マコトナワラタナ   牝5    56.0 川田将雅        栗東 鮫島一歩        6.2 
     8 ウイングザムーン   牝5    55.0 秋山真一郎      栗東 飯田明弘        2.2 
     9 ダイナミックガイ   牡4    55.0 小林徹弥        栗東 目野哲也       16.4 
    10 シルクドリーマー   牡5    55.0 北村友一        栗東 音無秀孝        6.6 
    11 ピースピース       牡8    54.0 上村洋行        美浦 和田雄二      203.4 
    12 アグネスウイッシュ 牡6    56.0 菱田裕二        栗東 長浜博之       15.1 
    13 フレデフォート     牡7    55.0 小牧太          栗東 安田隆行       39.4 
    14 テイエムタイホー   牡5    57.0 小坂忠士        栗東 鈴木孝志       65.7 
    15 アルティシムス     牡6    55.0 国分優作        栗東 野村彰彦       53.1 
    16 ラーストチカ       牝4    52.0 藤岡康太        栗東 宮徹           11.7 
    #num| bet type
    #---+--------------------
    #  0| 枠連
    #  1| 馬連
    #  2| ワイド
    #  3| 馬単
    #  4| 3連複
    #  5| 3連単
    # press a number to see odds or press 'q' to exit
    #> 

You can see the entry and win odds. Okey, press 1 to see quinella odds.

    #2014年1月26日(日) 1回京都9日
    #11R 石清水ステークス サラ系4歳以上 1600万円以下 (混合) ハンデ1400m 芝・右外 発走15:45
    #------------------------------------------------------------
    #馬連オッズ
    #----------
    1-2     1072.2
    1-3      517.8
    1-4     1404.6
    1-5     1523.2
    (snip)
    15-16    194.0
    $ 

That's all.

You can run it with args to get same the result as above.

     $ bundle exec bin/jra_info 5 11 1

TBD

## Limitations

* Not implemented trio(3連複) and trifecta(3連単)

## Contributing

1. Fork it (https://github.com/pot8os/jra_info/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT License

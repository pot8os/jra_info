# JraInfo

A simple client application to see the current information of Japanese Horseracing. All information are provided by [JRA](http://www.jra.go.jp)

## What you can get

* entry list of this weekend
* odds

## Installation

    $ git clone https://github.com/pot8os/jra_info.git
    $ cd jra_info
    $ bundle install

## Usage

Normal usage is just type the following command.

    $ bundle exec bin/jra_info

Running without any arguments as above is an 'interactive mode'. You can select course at first.

    #num| race course
    #---+--------------------
       1| 7月5日（土）2回福島1日
       2| 7月5日（土）3回中京1日
       3| 7月5日（土）2回函館1日
       4| 7月6日（日）2回福島2日
       5| 7月6日（日）3回中京2日
       6| 7月6日（日）2回函館2日
    # press a number to select a race course or 'q' to exit
    > 

If you want to see at Chukyo in Jul 6, press 5.

    # press a number to select a race course or 'q' to exit
    > 5
    #num| races (7月6日（日）3回中京2日)
    #---+--------------------
       1| 10:00 2歳未勝利（混合）［指定］  
       2| 10:30 3歳未勝利[指定]  
       3| 11:00 3歳未勝利牝［指定］  
       4| 11:30 3歳未勝利（混合）［指定］  
       5| 12:20 メイクデビュー中京 2歳新馬[指定]
       6| 12:50 メイクデビュー中京 2歳新馬牝［指定］
       7| 13:20 3歳未勝利[指定]  
       8| 13:50 3歳以上500万下[指定]  
       9| 14:25 美濃特別 3歳以上500万下（混合）（特指）
      10| 15:00 濃尾特別 3歳以上1000万下（混合）（特指）
      11| 15:35 ＣＢＣ賞 3歳以上オープン（国際）（特指）
      12| 16:15 3歳以上500万下（混合）［指定］  
    #-------------------------
    # add race number with character as follows (like '1a')
    # 出馬表=a, 単複=b, 枠連=c, 馬連=d, ワイド=e, 馬単=f, 3連複=g, 3連単=h
    # 'q' to exit
    > 

You have to type race number and information type. If you want to see an entry list of race 11, type 11a.

    # 'q' to exit
    > 11a
    #11R ＣＢＣ賞 3歳以上オープン（国際）（特指） 15:35
    #枠馬 馬名                 単勝     複勝    性齢  馬体重   斤量 騎手       調教師
    #--------------------------------------------------------------------------------
     1 1  リアルヴィーナス     11.7   2.7   3.4 牝3            50.0 藤岡康太   安達昭夫    
     1 2  ワキノブレイブ       18.1   4.7   6.1 牡4            54.0 幸英明     清水久詞    
     2 3  ルナフォンターナ      4.2   1.9   2.4 牝5            55.0 岩田康誠   池江泰寿    
     2 4  レオンビスティー     31.2   5.8   7.6 牡5            54.0 川須栄彦   矢作芳人    
     3 5  カイシュウコロンボ  132.0  13.6  18.1 牡6            54.0 太宰啓介   石橋守      
     3 6  サクラアドニス       87.4  10.5  13.9 牡6            54.0 国分恭介   村山明      
     4 7  ベルカント            3.1   1.9   2.4 牝3            52.0 武豊       角田晃一    
     4 8  エピセアローム        6.8   2.0   2.5 牝5            55.0 浜中俊     石坂正      
     5 9  スギノエンデバー     23.1   4.1   5.3 牡6            57.0 和田竜二   浅見秀一    
     5 10 ブルーデジャブ       34.0   4.2   5.4 せん7          54.0 国分優作   大根田裕之  
     6 11 トーホウアマポーラ    9.3   2.8   3.7 牝5            53.0 福永祐一   高橋亮      
     6 12 マヤノリュウジン     14.3   3.4   4.4 牡7            56.0 小牧太     庄野靖志    
     7 13 ティアップゴールド  130.6  21.9  29.0 牡8            53.0 北村友一   西浦勝一    
     7 14 マコトナワラタナ     23.3   4.2   5.5 牝5            53.0 川田将雅   鮫島一歩    
     8 15 スイートジュエリー   52.8   7.4   9.7 牝5            53.0 松山弘平   安田隆行    
     8 16 ニンジャ             23.8   4.5   5.9 牡5            54.0 酒井学     宮徹

That's all. You will see the information what you want as of now.

Also you can get the same result as above when you type using one liner as follows. 

     $ bundle exec bin/jra_info 5 11a

## with unix commands 

You can get some advantages by pipe!

    % bundle exec bin/jra_info 5 11h | grep -v # | sort -k2 | head -n 10                                                          
     7>3>8        49.5
     3>7>8        51.7
     3>8>7        65.2
     7>8>3        66.0
     7>3>1        78.1
     3>7>1        86.8
     8>3>7        98.0
     8>7>3        98.3
     7>1>3       116.9
     3>1>7       126.6
 
 If you are big fun of Yutaka... just do it! 
 
    % for i in {1..12}; do bundle exec bin/jra_info 5 ${i}a; done | egrep 'R|武豊'                 
    #1R 2歳未勝利（混合）［指定］   10:00
    #2R 3歳未勝利[指定]   10:30
    #3R 3歳未勝利牝［指定］   11:00
     7 14 ヤマニンバステト     11.4   3.6   4.7 牝3            54.0 武豊       千田輝彦    
    #4R 3歳未勝利（混合）［指定］   11:30
     4 7  オースミウルフ       15.7   3.9   7.8 牡3            56.0 武豊       加藤敬二    
    #5R メイクデビュー中京 2歳新馬[指定] 12:20
    #6R メイクデビュー中京 2歳新馬牝［指定］ 12:50
    #7R 3歳未勝利[指定]   13:20
    #8R 3歳以上500万下[指定]   13:50
     4 7  カーマンライン       12.4   3.5   6.0 牡3            54.0 武豊       今野貞一    
    #9R 美濃特別 3歳以上500万下（混合）（特指） 14:25
     7 10 スズカファイター     12.4   3.5   6.5 牡4            57.0 武豊       橋田満      
    #10R 濃尾特別 3歳以上1000万下（混合）（特指） 15:00
     3 5  アップトゥデイト     10.9   5.3   8.5 牡4            57.0 武豊       佐々木晶三  
    #11R ＣＢＣ賞 3歳以上オープン（国際）（特指） 15:35
     4 7  ベルカント            3.1   1.9   2.4 牝3            52.0 武豊       角田晃一    
    #12R 3歳以上500万下（混合）［指定］   16:15
     5 10 トーワフォーエバー   15.5   2.5   8.0 牝4            55.0 武豊       角田晃一 

## License

MIT License

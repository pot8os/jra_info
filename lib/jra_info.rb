# encoding: utf-8

require "jra_info/version"
require 'open-uri'
require 'net/http'
require 'uri'
require 'kconv'
require 'nokogiri'

class String
  def mb_ljust(width, padding=' ')
    output_width = each_char.map{|c| c.bytesize == 1 ? 1:2}.reduce(0, &:+)
    padding_size = [0, width - output_width].max
    self + padding * padding_size
  end

  def clean
    self.gsub('/\n/', '').strip
  end
end

class RaceInfo
  attr_accessor :id, :list, :time, :name, :tanfuku, :waku, :umaren, :wide, :umatan, :sanpuku, :santan
end

module JraInfo

  def self.run(argv)
    JraImpl.new(argv).execute
  end

  class JraImpl
    def initialize(argv)
      @argv = argv
    end

    def get_param(node)
      return node.attribute('onclick').value.scan(/(pw.*)'/).join
    end

    def get_contents(cname, url)
      host = 'http://jra.jp/'
      path = 'JRADB/access' + url + '.html'
      uri = URI.parse(host + path)
      doc = nil
      Net::HTTP.start(uri.host, uri.port) { |http|
        header = {
          "Origin" => host,
          "Referer" => host + path,
          "Cache-Control" => "max-age=0",
          "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          "Content-Type" => "application/x-www-form-urlencoded",
          "User-Agent" => "Opera/9.10 (Nintendo Wii; U; ; 1621; ja)"}
        body = "cname=" + cname
        response = http.post(uri.path, body, header)
        doc = Kconv.toutf8(response.body)
      }
      return Nokogiri::HTML(doc)
    end

    def create_first_link(doc)
      links = Hash.new([])
      id = 1
      doc.css('.joSelect').each do |n|
        day = n.css('th').text
        n.css('.joBtnBack').each do |m|
          m.css('.kaisaiBtn').each do |k|
            links[id] = {:course => day + k.text.clean, :param => get_param(k.css('a'))}
            id += 1
          end
        end
      end
      return links
    end

    def create_second_link(doc)
      links = Hash.new([])
      doc.css('td.raceNo').each do |n|
        race = RaceInfo.new()
        n.css('img').each do |k|
          race_no = k.attribute('alt').text
          if ! race_no.include?("WIN") then
            race.id = race_no
            race.list = get_param(k.parent)
          end
        end
        tr = n.parent
        race.time = tr.css('.hsj')[0].text.strip
        race.name = tr.css('.raceTitleUpper')[0].text.clean + " "
        race.name += tr.next_element.css('.raceTitleLower')[0].text.clean
        race.name = race.name.strip
        tr.css('img.oddsSelectBtn').each do |m|
          param = get_param(m.parent)
          type = m.attribute('src').text.match(/btn_(.*)\.gif/)[1]
          case type
          when "tanfuku"
            race.tanfuku = param
          when "waku"
            race.waku = param
          when "umaren"
            race.umaren = param
          when "wide"
            race.wide = param
          when "umatan"
            race.umatan = param
          when "sanpuku"
            race.sanpuku = param
          when "santan"
            race.santan = param
          end
        end
        links[race.id.gsub(/R/,'').to_i] = race
      end
      return links
    end

    def getvalue(tr, cname)
      val = tr.css('.' + cname)
      if val.length > 0 
        return val[0].text
      else
        return nil
      end
    end

    def show_entry_table(doc)
      puts "#枠馬 馬名                 単勝     複勝    性齢  馬体重   斤量 騎手       調教師"
      puts "#" + "-" * 80
      current_waku = nil
      doc.css('th.umaban').each do |n|
        tr = n.parent
        row = ' '
        [['waku', 2], ['umaban', 3], ['bamei', 19], ['oztan', 6], ['fukuMin', 6], ['fukuMax', 7], ['seirei', 6], ['batai', 9], ['futan', 5], ['kishu', 11], ['choukyou', 12]].each { |name, length|
          val = getvalue(tr, name)
          if name == 'waku'
            if val
              current_waku = val
            else
              val = current_waku
            end
          end
          row += val.mb_ljust(length)
        }
        puts row
      end
    end

    def show_tanfuku_odds(doc)
      puts "#" + "馬 馬名                 単勝"
      puts "#" + "-" * 30
      doc.css('th.umaban').each do |n|
        tr = n.parent
        row = ' '
        [['umaban', 3], ['bamei', 19], ['oztan', 6]].each { |name, length|
          row += getvalue(tr, name).mb_ljust(length)
        }
        puts row
      end
    end

    def show_waku_odds(doc)
      puts "# 枠連オッズ"
      puts "#" + "-" * 10
      doc.css('table.ozWakuINTable').each do |n|
        jiku = n.css('tr')[0].text.clean
        n.css('td.tdoz').each do |m|
          puts (jiku + "-" + m.parent.first_element_child.text.clean).rjust(4) + m.text.clean.rjust(6)
        end
      end
    end

    def show_umaren_odds(doc)
      puts "# 馬連オッズ"
      puts "#" + "-" * 10
      doc.css('table.ozUmarenUmaINTable').each do |n|
        jiku = n.css('tr')[0].text.clean
        n.css('th.thubn').each do |m|
          puts (" " + jiku + "-" + m.text.clean).ljust(5) + m.parent.css('.tdoz')[0].text.clean.rjust(7)
        end
      end
    end

    def show_wide_odds(doc)
      puts "# ワイドオッズ"
      puts "#" + "-" * 20
      doc.css('table.ozWideUmaINTable').each do |n|
        jiku = n.css('tr')[0].text.clean
        n.css('th.thubn').each do |m|
          row = m.parent
          puts " " + (jiku + "-" + m.text.clean).ljust(6) + row.css('.wideMin')[0].text.rjust(5) + " -" + row.css('.wideMax')[0].text.rjust(5)
        end
      end
    end

    def show_umatan_odds(doc)
      puts "# 馬単オッズ"
      puts "#" + "-" * 20
      doc.css('table.ozUmatanUmaINTable').each do |n|
        jiku = n.css('tr')[0].text.clean
        n.css('th.thubn').each do |m|
          if jiku != m.text
            puts " " + (jiku + ">" + m.text).ljust(6) + m.parent.css('.tdoz')[0].text.rjust(6)
          end
        end
      end
    end

    def show_sanpuku_odds(doc)
      puts "# 3連複オッズ"
      puts "#" + "-" * 20
      doc.css('table.ozSanrenUmaINTable').each do |n|
        jiku = n.css('th')[0].text
        n.css('th.thubn').each do |m|
         puts " " + (jiku + "-" + m.text).ljust(9) + m.parent.css('.tdoz')[0].text.rjust(7)
        end
      end
    end

    def show_santan_odds(doc)
      puts "# 3連単オッズ"
      puts "#" + "-" * 20
      doc.css('table.santanOddsHyo').each do |n|
        first = n.css('.ubn2')[0].text
        second_array = n.css('tr')[1].css('.ubn2')
        third_array = n.css('table.oddsTbl')
        second_array.each_with_index { |second, i|
          third_array[i].css('.ubn3').each do |m|
            pair = first + ">" + second.text.clean + ">" + m.text.clean
            odds = m.parent.css('td')[0].text.clean
            if odds == "票数なし"
              odds = "0"
            end
            if odds != "---"
              puts " " + pair.ljust(9) + odds.rjust(8)
            end
          end
        }
      end
    end

    def evaluate_arg(arg)
      if arg == "q"
        exit
      end
      if /^[0-9]*$/ =~ arg
        return arg.to_i
      else
        return arg
      end
    end

    def execute
      map = create_first_link(get_contents('pw15oli00/6D','O'))
      input = @argv.shift 
      if input == nil
        puts "#num| race course"
        puts "#---+" + "-" * 20
        map.each do |k, v|
          puts k.to_s.rjust(4) + "| " + v[:course]
        end
        puts "# press a number to select a race course or 'q' to exit"
        print "> "
        input = STDIN.gets.chomp
      end
      select_key = evaluate_arg(input)
      course = map[select_key][:course]
      map = create_second_link(get_contents(map[select_key][:param],'P'))
      input = @argv.shift
      if input == nil
        puts "#num| races (" + course +")"
        puts "#---+" + "-" * 20
        map.each do |k, v|
          puts k.to_s.rjust(4) + "| "+ v.time.rjust(5) + " " + v.name
        end
        puts "#" + "-" * 25
        puts "# add race number with character as follows (like '1a')"
        puts "# 出馬表=a, 単複=b, 枠連=c, 馬連=d, ワイド=e, 馬単=f, 3連複=g, 3連単=h"
        puts "# 'q' to exit"
        print "> "
        input = STDIN.gets.chomp
      end
      select_key = evaluate_arg(input)
      race = map[select_key.chop.to_i]
      info_type = input.split('').last
      puts "#" + race.id + " " + race.name + " " + race.time
      case info_type
      when "a"
        show_entry_table(get_contents(race.list, 'O'))
      when "b"
        show_tanfuku_odds(get_contents(race.tanfuku, 'O'))
      when "c"
        show_waku_odds(get_contents(race.waku, 'O'))
      when "d"
        show_umaren_odds(get_contents(race.umaren, 'O'))
      when "e"
        show_wide_odds(get_contents(race.wide, 'O'))
      when "f"
        show_umatan_odds(get_contents(race.umatan, 'O'))
      when "g"
        show_sanpuku_odds(get_contents(race.sanpuku, 'O'))
      when "h"
        show_santan_odds(get_contents(race.santan, 'O'))
      end
    end
  end
end


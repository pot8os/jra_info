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
      return node.attribute('onclick').value.scan(/(sw.*)'/).join
    end

    def get_contents(cname, url)
      host = 'http://sp.jra.jp'
      path = '/JRADB/access'+url+'.html'
      uri = URI.parse(host+path)
      doc = nil
      Net::HTTP.start(uri.host,uri.port){|http|
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
      doc.css('div#shutsubahyo').css('.joBtn').each do |n|
        if n.child.text.gsub(/\s/, '').length > 0
          course = n.parent.parent.parent.previous.previous.text + " " + n.text.gsub(/\s/, '')
          links[id] = {:course => course,:param => get_param(n)}
          id += 1
        end
      end
      return links
    end

    def create_second_link(doc)
      links = Hash.new([])
      id = 1
      doc.css('div#denRaceList').css('tr').each do |race_row|
        info = race_row.css('.raceNo').text.match(/([0-9]{1,2}R)([0-9:]{4,5})/)
        race_no = info[1]
        race_time = info[2]
        a_dom = race_row.css('a')
        race_name = a_dom.children[0].text.gsub(/\s/,'')
        if a_dom.children.length == 4
          race_name = race_name+"("+ a_dom.children[1].attr('alt')+")"
        end
        race_condition = a_dom.children[a_dom.children.length-2].text
        links[id] = {:no => race_no, :time => race_time, :param => get_param(a_dom), :name => race_name, :condition => race_condition}
        id += 1
      end
      return links
    end

    def create_third_link(doc)
      print "#" + doc.css('.subTitle').text + "\n"
      print "#" + doc.css('.kyosoMei').text + " " + doc.css('.kyosoJoken span').text.gsub(/\s/,'') + "\n"
      print "#" + "-" * 60 + "\n"
      if @argv[0] == nil || @argv[0] == "q"
        id = 0
        doc.css('.denTable tr').each do |horse_row|
          if id > 0
            print horse_row.css('.uban').text.rjust(2)
            horse = horse_row.css('.uma') 
            print " "+horse.css('span.bamei').text.mb_ljust(19)
            print horse.children[5].text.scan(/せ*[牡牝ん][0-9]{1,2}/).join.mb_ljust(7)
            horse.css('span a').each do |node|
              print node.next.text.gsub(/\s/,'').gsub(/[\(\)]/,'').rjust(4)
              print " "+node.text.mb_ljust(14)
            end
            print horse.css('.tanOz').text.gsub(/(\(.*\))/,'').rjust(6)
            print "\n"
          end
          id += 1
        end
      end
      buttons = doc.css('.shutubahyoToBtnArea a')
      return get_odds_selector(get_contents(get_param(buttons[buttons.length-1]),'O'))
    end

    def get_odds_selector(doc)
      links = Hash.new([])
      id = 0
      doc.css('.oddsSelectBtn').each do |selector|
        a = selector.css('a')
        type = a.text
        links[id] = {:type => type, :param => get_param(a)}
        id += 1
      end
      return links
    end

    def create_bracket_quinella_odds(doc)
      print "#枠連オッズ\n#"+"-"*10+"\n"
      jiku = nil
      doc.css('.ozWakuInTable tr').each do |odds|
        if odds.children.length == 2
          jiku = odds.css('th').text
        else
          print (jiku+"-"+odds.css('th').text).ljust(5)+odds.css('.tdoz').text+"\n"
        end
      end
    end

    def create_quinella_odds(doc)
      print "#馬連オッズ\n#"+"-"*10+"\n"
      doc.css('.ozUmaInTable tr').each do |odds|
        if odds.children.length == 4
          print odds.css('.kumiNo').text.ljust(6)+odds.css('.oz').text+"\n"
        end
      end
    end

    def create_quinella_place_odds(doc)
      print "#ワイドオッズ\n"+"-"*10+"\n"
      doc.css('.ozWideInTable tr').each do |odds|
        if odds.children.length == 6
          print odds.css('.kumiNo').text.ljust(6)+odds.css('.wideMin').text+" - "+odds.css('.wideMax').text+"\n"
        end
      end
    end

    def create_exacta_odds(doc)
      print "#馬単オッズ\n#"+"-"*15+"\n"
      doc.css('.ozUmaInTable tr').each do |odds|
        if odds.children.length == 4
          print odds.css('.kumiNo').text.ljust(6)+odds.css('.oz').text+"\n"
        end
      end
    end

    def evaluate_arg(arg)
      if arg == "q"
        exit
      end
      return arg.to_i
    end



    def execute
      map = create_first_link(get_contents('sw01dli00/80','D'))
      input = @argv.shift 
      if input == nil
        print "#num| race course\n"
        print "#---+"+"-"*20+"\n"
        map.each do |k, v|
          print k.to_s.rjust(4) + "| " + v[:course] + "\n"
        end
        print "# press a number to select a race course or 'q' to exit\n#> "
        input = STDIN.gets.chomp
      end
      select_key = evaluate_arg(input)
      course = map[select_key][:course]
      map = create_second_link(get_contents(map[select_key][:param],'P'))
      input = @argv.shift
      if input == nil
        print "#num| races (" + course +")\n"
        print "#---+"+"-"*20+"\n"
        map.each do |k, v|
          print k.to_s.rjust(4) + "| " + v[:no].rjust(3) + v[:time].rjust(6) + " " + v[:name] + " " + v[:condition] + "\n"
        end
        print "# press a number to see entries or 'q' to exit\n#> "
        input = STDIN.gets.chomp
      end
      select_key = evaluate_arg(input)
      race = map[select_key][:name]
      map = create_third_link(get_contents(map[select_key][:param],'D'))
      input = @argv.shift
      if input == nil
        print "#num| bet type\n"
        print "#---+"+"-"*20+"\n"
        map.each do |k, v|
          print "#"+k.to_s.rjust(3) + "| " + v[:type] + "\n"
        end
        print "# press a number to see odds or press 'q' to exit\n#> "
        input = STDIN.gets.chomp
      end
      select_key = evaluate_arg(input)
      doc = get_contents(map[select_key][:param],'O')
      case select_key
      when 0
        create_bracket_quinella_odds(doc)
      when 1
        create_quinella_odds(doc)
      when 2
        create_quinella_place_odds(doc)
      when 3
        create_exacta_odds(doc)
      when 4
        raise NotImplmentedError
      when 5
        raise NotImplmentedError
      end
    end
  end
end

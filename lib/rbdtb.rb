require 'awesome_print'
require 'rly'
require 'logger'
require 'pathname'

$log = Logger.new(STDOUT)
$log.level = Logger::WARN


class DTBLex < Rly::Lex
  literals "=():;,{}+"
  ignore " \t\n"

  token :HEX, /0[x|X]\d+/ do |t|
    t
  end

  token :NUMBER, /\d+/ do |t|
    t.value = t.value.to_i
    t
  end


  token :COMMENTS, /\/\*((?!\/\*).)+\*\// do |t|
    t
  end

  token :VERSION, /\/dts-v\d+\/;/ do |t|
    t
  end

  token :ROOT, /\/\s+/ do |t|
    t
  end

  token :SINGLESTRING, /\"[^\"]+\"/ do |t|
    t
  end

  token :BINARYDATA, /\[[^\[]+\]/ do |t|
    t
  end

  token :CELLDATA, /<[^<]+>/ do |t|
    t
  end

  token :DATA, /[a-zA-Z_][@a-zA-Z0-9_-]*/ do |t|
    t
  end

  token :DATA, /[#\/a-zA-Z_][a-zA-Z0-9_-]*\.[\/a-zA-Z_]*/ do |t|
    t
  end

  token :DATA, /[\/#a-zA-Z_][@\/a-zA-Z0-9_-]*/ do |t|
    t
  end

  token :BITS, /\/bits\// do |t|
    t
  end

  token :REFERENCE, /&[a-zA-Z_][a-zA-Z0-9_-]*/ do |t|
    t
  end

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end

  def show()
    while tok = self.next do
        puts "#{tok.type} -> #{tok.value}"
    end
  end
end


class DTBParse < Rly::Yacc
  def stack
    @stack ||= {}
  end

  rule 'statement : expression' do |st, ex|
    st.value = ex.value
    $log.info "statement #{st.value}"
  end

  rule 'expression : VERSION expression' do |ex, v, e|
    ex.value = {"version" => v.value}.merge(e.value)
    $log.info "expression VERSION e #{ex.value}"
  end

  rule 'expression : expression "=" expression ' do |ex, e1, _, e2|
    ex.value = {e1.value => e2.value}
    $log.info "expression = #{ex.value}"
  end

  rule 'expression : DATA "{" "}"' do |ex, d, _, _|
    ex.value = { d.value => "" }
    $log.info "rule data { } #{ex.value}"
  end

  rule 'expression : ROOT "{" expression "}" ' do |ex, _, _, e, _|
    ex.value = {"root" => e.value.merge(self.stack)}
    self.stack.clear()
    $log.info "rule \/ { e } #{ex.value}"
  end

  rule 'expression : DATA "{" expression "}"' do |ex, d, _, e, _|
    if e.value.class == Hash
      ex.value = {d.value => e.value.merge(self.stack)}
    else
      data = {e.value => ''}
      ex.value = {d.value => data.merge(self.stack)}
    end
    self.stack.clear()
    $log.info  "rule data { e }  #{ex.value}"
  end

  rule 'expression : NUMBER "{" expression "}"' do |ex, d, _, e, _|
    if e.value.class == Hash
      ex.value = {d.value => e.value.merge(self.stack)}
    else
      data = {e.value => ''}
      ex.value = {d.value => data.merge(self.stack)}
    end
    self.stack.clear()
    $log.info  "rule NUMBER { e }  #{ex.value}"
  end  


  rule 'expression : "{" expression "}"' do |ex,  _, e, _|
    if e.value.class == Hash
      ex.value = e.value.merge(self.stack)
    else
      data = {e.value => ''}
      ex.value = self.stack
    end
    self.stack.clear()
    $log.info  "rule { e }  #{ex.value}"
  end

  rule 'expression : BITS expression' do |ex, _, e1,|
    ex.value = e1.value.to_s
    $log.info  "rule BITS expression  #{ex.value}"
  end

  rule 'expression : DATA DATA' do |ex, e1, e2,|
    ex.value = e1.value + " " + e2.value
    $log.info  "rule DATA DATA  #{ex.value}"
  end

  rule 'expression : expression ":" expression' do |ex, e1, op, e2|
    ex.value = {e1.value => e2.value}
    $log.info "rule e : e #{ex.value}"
  end

  rule 'expression : DATA "," expression' do |ex, d, _, e|
    if e.value.class == Hash
      mh = { d.value + "," + e.value.keys()[0].to_s =>  e.value.values()[0] }
      ex.value = mh
    else
      ex.value = {d.value => e.value}
    end
    $log.info "rule DATA , expression #{ex.value}"
  end

  rule 'expression : expression "," expression' do |ex, e1, op, e2|
    tv1 = [ ]
    if e1.value.class == Array
        tv1 = e1.value
    else
        tv1 = [e1.value]
    end
    tv2 = []
    if e2.value.class == Array
        tv2 = e2.value
    else
        tv2 = [e2.value]
    end
    ex.value = tv1 | tv2
    $log.info  "rule ,  #{ex.value}"
  end

  rule 'expression : expression ";"'do |ex, e1, op|
    if e1.value.class == Hash
      ex.value = e1.value
    else
      ex.value = e1.value
    end
    $log.info "rule expression ; #{ex.value}"
  end

  rule 'expression : expression ";" expression' do |ex, e1, op, e2|
    ex.value = e1.value
    begin
      self.stack.merge!(e2.value)
    rescue
      if e2.value.class == Array
        mh = { e2.value[0].to_s + "," + e2.value[1].keys()[0].to_s =>  e2.value[1].values()[0] }
        self.stack.merge!(mh)
      elsif e2.value.class == Integer or e2.value.class == String
        mh = {e2.value => ""}
        self.stack.merge!(mh)
      else
        raise "sematic error #{e1.value} ; #{e2.value}"
      end
    end
    $log.info "rule expression e ; e #{ex.value}"
  end  

  rule 'expression : HEX expression' do |ex, h, e|
    ex.value = h.value.to_s + " " + e.value.to_s
    $log.info  "rule HEX expression #{ex.value}"
  end

  rule 'expression : expression COMMENTS ' do |ex, e,  _|
    ex.value =  e.value
    $log.info  "rule e COMMENTS #{ex.value}"
  end

  rule 'expression : COMMENTS expression' do |ex, _,  e|
    ex.value =  e.value
    $log.info  "rule e COMMENTS #{ex.value}"
  end

  rule 'expression : COMMENTS ' do |ex, _|
    ex.value =  ""
    $log.info  "rule COMMENTS #{ex.value}"
  end

  rule 'expression : CELLDATA' do |ex, n|
    ex.value = n.value
    $log.info "rule CELLDFATA #{ex.value}"
  end

  rule 'expression : BINARYDATA' do |ex, n|
    ex.value = n.value
    $log.info "rule BINARYDATA #{ex.value}"
  end

  rule 'expression : SINGLESTRING ' do |ex, n|
    ex.value = n.value
    $log.info "rule SINGLESTRING #{ex.value}"
  end

  rule 'expression : NUMBER' do |ex, n|
    ex.value = n.value
    $log.info  "rule NUMBER  #{ex.value}"
  end

  rule 'expression : DATA' do |ex, n|
    ex.value = n.value
    $log.info  "rule DATA  #{ex.value}"
  end

  rule 'expression : BITS ' do |ex, n|
    ex.value = n.value
    $log.info  "rule BITS  #{ex.value}"
  end

  rule 'expression : REFERENCE ' do |ex, n|
    ex.value = n.value.gsub("&", "")
    $log.info  "rule REFERENCE  #{ex.value}"
  end

  #store_grammar 'grammar.txt'

end

def pre_process(in_string)
  ps1 = in_string.gsub(/\/\/.+$/, "").split("\n").join().gsub(/\s+/, "\s").gsub(/\s=\s/, '=')
end


def dtb_parse_string(in_string)
  parse_string = pre_process(in_string)
  parser = DTBParse.new(DTBLex.new)
  return parser.parse(parse_string)
end

def dtb_parse_file(file_path)
  begin
  file = File.open(file_path)
  rescue
    puts "#{file_path} open error"
  end
  return dtb_parse_string(file.read)
end

if __FILE__ == $0
  $log.level = Logger::INFO
=begin
  test_string = '''
      /dts-v1/;

      / {
          node1 {
              a-string-property = "A string";
              a-string-list-property = "first string", "second string";
              // hex is implied in byte arrays. no \'0x\' prefix is required
              a-byte-data-property = [01 0x23 34 56];
              child-node1 {
                  first-child-property;
                  second-child-property = <1>;
                  a-string-property = "Hello, world";
              };
              child-node2 {
              };
          };
          node2 {
              a-cell-property = <1 2 3 4>; /* each number (cell) is a uint32 */
              an-empty-property;
              child-node1 {
              };
          };
      };
  '''
  lex = DTBLex.new(test_string)
  lex.show()
  ap dtb_parse_string(test_string)
=end
  #ap dtb_parse_file("../test/sample.dts_compiled")
  
  ap dtb_parse_file("../test/frdm_kw41z.dts_compiled")
end
from antlr4_systemverilog import InputStream, CommonTokenStream
from antlr4_systemverilog.systemverilog import SystemVerilogLexer, SystemVerilogParser, SystemVerilogPreParser
from antlr4.ListTokenSource import ListTokenSource

def parse(Design):
   lexer = SystemVerilogLexer(InputStream(Design))
   token_stream = CommonTokenStream(lexer)

   # 填充Token流
   token_stream.fill()

   # 创建一个空列表来存储DIRECTIVES通道的Tokens
   directive_tokens = []

   # 遍历token_stream中的所有Tokens
   for token in token_stream.tokens:
      # 检查token的通道是否是DIRECTIVES
      if token.channel != 2:
         # 如果是，将token添加到directive_tokens列表中
         directive_tokens.append(token)


   # 如果没有找到DIRECTIVES通道的Tokens，直接返回EOF
   if not directive_tokens:
      print("No DIRECTIVES tokens found")
      return None

   # 创建新的TokenStream仅包含DIRECTIVES通道的Tokens
   directive_token_source = ListTokenSource(directive_tokens)
   filtered_token_stream = CommonTokenStream(directive_token_source)

   # 创建Parser并解析
   parser = SystemVerilogParser(filtered_token_stream)
   return parser

"This function is used to convert the systemverilog to a tree"
def parse_design_to_tree(Design):
   parser = parse(Design)
   tree = parser.source_text()
   return tree

def parse_port_to_tree(Design):
   parser = parse(Design)
   tree = parser.list_of_port_declarations()
   return tree

def parse_parameter_to_tree(Design):
   parser = parse(Design)
   tree = parser.module_parameter_port_list()
   return tree

def parse_module_to_tree(Design):
   parser = parse(Design)
   tree = parser.module_item()
   return tree

def parse_net_declare_to_tree(Design):
   parser = parse(Design)
   tree = parser.net_declaration()
   return tree

def parse_reg_declare_to_tree(Design):
   parser = parse(Design)
   tree = parser.reg_declaration()
   return tree

def parse_mod_ins_to_tree(Design):
   parser = parse(Design)
   tree = parser.module_instantiation()
   return tree
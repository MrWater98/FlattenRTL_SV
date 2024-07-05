from antlr4_systemverilog import InputStream, CommonTokenStream
from antlr4_systemverilog.systemverilog import SystemVerilogLexer, SystemVerilogParser

def parse(Design):
   lexer = SystemVerilogLexer(InputStream(Design))
   stream = CommonTokenStream(lexer)
   parser = SystemVerilogParser(stream)
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
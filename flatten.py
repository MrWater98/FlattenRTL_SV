import re, copy

from antlr4.tree.Tree import TerminalNodeImpl
from antlr4_systemverilog.systemverilog import SystemVerilogParser, SystemVerilogParserVisitor

from design_parser import parse_design_to_tree

class TopModuleNodeFinder(SystemVerilogParserVisitor):
    def __init__(self, top_module):
        self.top_module_node= None
        self.top_module = top_module   
        
    def visitModule_declaration(self, ctx: SystemVerilogParser.Module_declarationContext):
        module_name = ctx.module_header().module_identifier().getText()
        if module_name == self.top_module:
            self.top_module_node = ctx
            
class MyModuleInstantiationVisitor(SystemVerilogParserVisitor):
    def __init__(self):
        self.is_first_instantiation_module = False
        self.module_identifier = ""
        self.module_param = []
        self.name_of_module_instances = []
        self.list_of_ports_rhs = []
        self.dict_of_lhs_to_rhs = {}
        self.list_of_ports_rhs_width = []
        self.dict_of_parameters = {}

    def visitModule_program_interface_instantiation(
        self, ctx : SystemVerilogParser.Module_program_interface_instantiationContext
    ):
        if (
            self.is_first_instantiation_module == False
            or self.module_identifier == ctx.instance_identifier().getText()
        ):
            self.is_first_instantation_module = True
            self.first_instantiation = ctx
            self.module_identifier = ctx.instance_identifier().getText()
            self.name_of_module_instances.append(
                ctx.hierarchical_instance()[0].name_of_instance().getText()
            )
        # get ports_connnections
        ports_connections = ctx. hierarchical_instance()[0].list_of_port_connections()
    
        for child in ports_connections.getChildren():
            if child in ports_connections.getChildren():
                if isinstance(child, TerminalNodeImpl):
                    pass
                else:
                    if child.port_assign().expression() is not None:
                        self.list_of_ports_rhs.append(child.port_assign().getText())
                    else:
                        self.list_of_ports_rhs.append("")
                    if isinstance(child, SystemVerilogParser.Ordered_port_connectionContext):
                        if (self.dict_of_lhs_to_rhs.get(self.name_of_module_instances[-1]) is None):
                            self.dict_of_lhs_to_rhs[self.name_of_module_instances[-1]] = {}
                    elif (isinstance(child, SystemVerilogParser.Named_port_connectionContext) is not None):
                        if (self.dict_of_lhs_to_rhs.get(self.name_of_module_instances[-1])is None):
                            self.dict_of_lhs_to_rhs[self.name_of_module_instances[-1]] = {}
                        if child.port_assign() is not None:
                            self.dict_of_lhs_to_rhs[self.name_of_module_instances[-1]][child.port_identifier().getText()] = child.port_assign().expression().getText()
                            
                            self.dict_of_lhs_to_rhs[self.name_of_module_instances[-1]][child.port_identifier().getText()] = \
                                self.dict_of_lhs_to_rhs[self.name_of_module_instances[-1]][child.port_identifier().getText()].replace("?", " ? ")
                        else:
                            self.dict_of_lhs_to_rhs[self.name_of_module_instances[-1]][child.port_identifier().getText()] = ""
                          
class InstModuleVisitor(SystemVerilogParserVisitor):
    def __init__(self, cur_module_identifier):
        self.inst_module_node = None
        self.inst_module_design = None
        self.start = None   
        self.stop = None 
        self.indent = 2
        self.cur_module_identifier = cur_module_identifier

        self.parameter_strat = None
        self.parameter_stop = None
        self.ports_param_str = None
        
    def visitModule_declaration(self, ctx: SystemVerilogParser.Module_declarationContext):
        module_name = ctx.module_header().module_identifier().getText()
        if module_name == self.cur_module_identifier:
            self.start = ctx.start.start
            self.stop = ctx.stop.stop
            self.inst_module_node = ctx

              

        
                    

            
def pyflattenverilog(design: str, top_module: str):
    tree = parse_design_to_tree(design)
    
    top_finder= TopModuleNodeFinder(top_module)
    top_finder.visit(tree)
    top_node_tree = top_finder.top_module_node 
    
    visitor = MyModuleInstantiationVisitor()
    visitor.visit(top_node_tree)
    cur_module_identifier =visitor.module_identifier
    cur_name_of_module_instances = visitor.name_of_module_instances
    cur_prefixs = cur_name_of_module_instances
    cur_list_of_ports_rhs = visitor.list_of_ports_rhs
    cur_list_of_parameters = visitor.dict_of_parameters
    dict_of_lhs_to_rhs = visitor.dict_of_lhs_to_rhs
    
    # If we cannot find the current module identifier
    if cur_module_identifier == "":
        return True, design[top_node_tree.start.start : top_node_tree.stop.stop + 1]
    else:
        print(
            "[Processing] MODULE: %s\tNAME:%s"
            % (cur_module_identifier, cur_name_of_module_instances)
        )
    
    visitor = InstModuleVisitor(cur_module_identifier=cur_module_identifier)
    visitor.visit(tree)
    inst_module_design = design[visitor.start : visitor.stop + 1]
    
    
    
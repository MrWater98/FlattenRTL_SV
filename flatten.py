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
            self.is_first_instantiation_module = True
            self.first_instantiation = ctx
            self.module_identifier = ctx.instance_identifier().getText()
            self.name_of_module_instances.append(
                ctx.hierarchical_instance()[0].name_of_instance().getText()
            )
            # get ports_connnections
            ports_connections = ctx.hierarchical_instance()[0].list_of_port_connections()
        
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

class RenameModuleVisitor(SystemVerilogParserVisitor):
    def __init__(self,cur_prefixs_index,cur_prefixs,cur_module_identifier):
        self.inst_module_node = None
        self.inst_module_design = None
        self.start = None
        self.stop = None
        self.indent = 2
        self.cur_prefixs_index = cur_prefixs_index
        self.is_no_port_parameter = False
        self.port_parameter_flag = False
        self.cur_prefixs =cur_prefixs
        self.cur_module_identifier = cur_module_identifier
    
    def is_parents_function_declaration(self,ctx):
        if ctx is None:
            return False
        if not isinstance(ctx, SystemVerilogParser.Function_declarationContext):
            return self.is_parents_function_declaration(ctx.parentCtx)
        else:
            return True
        
        "This function is used to traverse the tree and change the name of the instance"
    
    def _traverse_children(self,ctx):
        if isinstance(ctx,TerminalNodeImpl):
            if ctx.symbol.text == "?":
                ctx.symbol.text = "?"
        else:
            for child in ctx.getChildren():
                if isinstance(child,SystemVerilogParser.Simple_identifierContext):
                    if isinstance(
                        child.parentCtx.parentCtx,
                        SystemVerilogParser.Module_identifierContext,
                    ):
                        pass
                    elif isinstance(
                        child.parentCtx.parentCtx,
                        SystemVerilogParser.Instance_identifierContext,
                    ):
                        pass
                    elif isinstance(
                        child.parentCtx.parentCtx,
                        SystemVerilogParser.Port_identifierContext,
                    ):
                        if self.is_parents_function_declaration(child):
                            child.start.text = (
                                ""
                                + self.cur_prefixs[self.cur_prefixs_index]
                                + "_"
                                + child.start.text
                                + ""
                            )
                        else:
                            pass
                    elif isinstance(
                        child.parentCtx.parentCtx,
                        SystemVerilogParser.Param_assignmentContext,
                    ):
                        pass
                    else:
                        child.start.text = (
                            ""
                            + self.cur_prefixs[self.cur_prefixs_index]
                            + "_"
                            +child.start.text
                            + ""
                        )
                self._traverse_children(child)
                            
                            
                            
    
    def visitModule_declaration(self,ctx:SystemVerilogParser.Module_declarationContext):
        module_name = ctx.module_header().module_identifier().getText()
        if module_name == self.cur_module_identifier:
            self.start = ctx.start.start
            self.stop = ctx.stop.stop
            self.inst_module_node = ctx 
            self._traverse_children(self.inst_module_node)    


class InstModulePortVisitor (SystemVerilogParserVisitor):
    def __init__(self,cur_module_identifier):
        self.inst_module_node = None
        self.is_first_instantiation_module = False
        self.list_of_ports_width = []
        self.list_of_ports_direction = []
        self.list_of_ports_type = []
        self.list_of_data_type = []
        self.list_of_ports_lhs = []
        self.cur_module_identifier = cur_module_identifier
        
    def _traverse_children(self,ctx):
        if isinstance(ctx, TerminalNodeImpl):
            if ctx.symbol.text == "?":
                ctx.symbol.text = "?"
        else:
            for child in ctx.getChildren():
                if isinstance(child, SystemVerilogParser.Port_directionContext) \
                    and child.getText()=='input':
                    self.list_of_ports_direction.append(child.INPUT().getText())
                    self.list_of_ports_lhs.append(
                        child.parentCtx.port_identifier().getText()
                    )
                    self.list_of_ports_type.append("wire")
                    if child.parentCtx.implicit_data_type() is not None:
                        if child.parentCtx.implicit_data_type().packed_dimension() is not None:
                            self.list_of_ports_width.append(child.parentCtx.implicit_data_type().packed_dimension()[0].getText())
                        else:
                            self.list_of_ports_width.append("")
                        if child.parentCtx.implicit_data_type().signing() is not None:
                            self.list_of_data_type.append(child.parentCtx.implicit_data_type().signing().getText())
                        else:
                            self.list_of_data_type.append("")
                    else:
                        self.list_of_ports_width.append("")
                        self.list_of_data_type.append("")
                        
                    # TODO: data_type() is not none
                        
                    
                if isinstance(child, SystemVerilogParser.Port_directionContext) \
                        and child.getText()=='output':
                    self.list_of_ports_direction.append(child.getText())
                    
                    if child.parentCtx.data_type() is not None:
                        self.list_of_ports_type.append(child.parentCtx.data_type().integer_vector_type().getText())
                    else:
                        self.list_of_ports_type.append("wire")
                        
                    if child.parentCtx.port_identifier() is not None:
                        self.list_of_ports_lhs.append(
                            child.parentCtx.port_identifier().getText()
                        )
                    else:
                        self.list_of_ports_lhs.append(
                            child.list_of_variable_port_identifiers().getText()
                        )
                    if child.parentCtx.implicit_data_type():
                        if child.parentCtx.implicit_data_type().packed_dimension() is not None:
                            # TODO: Incorrect for multiple packed
                            self.list_of_ports_width.append(child.parentCtx.implicit_data_type().packed_dimension()[0].getText())
                        else:
                            self.list_of_ports_width.append("")
                            
                        if child.parentCtx.implicit_data_type().signing() is not None :
                            self.list_of_data_type.append(
                                child.parentCtx.implicit_data_type().signing().getText()
                            )
                        else:
                            self.list_of_data_type.append("")
                    else:
                        self.list_of_ports_width.append("")
                        self.list_of_data_type.append("")
                    # TODO: data_type() is not none
                    
                        
                    # TODO: inout
                    if isinstance(child,SystemVerilogParser.Inout_declarationContext):
                        self.list_of_ports_direction.append(child.INOUT().getText())
                        self.list_of_ports_lhs.append(
                            child.list_of_port_identifiers.getText()
                        )
                        self.list_of_ports_type.append("wire")
                        if child.range_()is not None:
                            self.list_of_ports_width.append(child.range_().getText())
                        else:
                            self.list_of_ports_width.append("")
                            
                        if child.SIGNED()is not None:
                            self.list_of_data_type.append(child.SIGNED().getText())
                        else:
                            self.list_of_data_type.append("")     
                self._traverse_children(child)    
    
    
    def visitModule_declaration(self, ctx:SystemVerilogParser.Module_declarationContext):
        module_name = ctx.module_header().module_identifier().getText()
        if module_name == self.cur_module_identifier:
            self.start = ctx.start.start
            self.stop = ctx.stop.stop
            self.inst_module_node = ctx
            self._traverse_children(self.inst_module_node)        
                   
class InstBodyVisitor(SystemVerilogParserVisitor):
    def __init__(self):
        super().__init__()
        self.inst_module_node = None
        self.inst_module_design = None
        self.text = ""
    def formatProcess(self,ctx):
        self._traverse_children(ctx)
        if ctx.getChildCount() == 0:
            return ""
        
        temp = ""
        for child in ctx.getChildren():
            temp += child.getText() + " "
            
        for line in temp.splitlines():
            for char in line:
                if char == chr(31):
                    self.text += "\n"
                else:
                    self.text += char
    def _traverse_children(self,ctx,indent=0):
        if isinstance(ctx, TerminalNodeImpl):
            pass
        else:
            for child in ctx.getChildren():
                if isinstance(child,SystemVerilogParser.List_of_port_declarationsContext):
                    child.start.text = (
                        chr(31) + " " * indent + child.start.text + " "
                    )
                if isinstance(child, SystemVerilogParser.Data_declarationContext):
                    if child.data_type().getText()=="reg":
                        child.start.text = chr(31) + " " * indent +child.start.text
                    elif child.data_type().getText()=="integer":
                        child.start.text = chr(31) + " " * indent +child.start.text
                if isinstance(child, SystemVerilogParser.Net_declarationContext):
                    child.start.text = chr(31) + " " * indent +child.start.text
                if isinstance(child,SystemVerilogParser.Continuous_assignContext):
                    child.start.text = (
                        chr(31) + " " * indent +child.start.text + " "
                    )
                if isinstance(child,SystemVerilogParser.Always_constructContext):
                    child.start.text = (
                        chr(31) + " " *indent + child.start.text + " "
                    )
                    child.stop.text = child.stop.text + chr(31)
                if isinstance(child,SystemVerilogParser.Event_expressionContext):
                    child.start.text = " " + child.start.text + " "
                if isinstance(child,SystemVerilogParser.Case_statementContext):
                    child.start.text = (
                        chr(31) + " " * indent + child.start.text + " "
                    )
                    child.stop.texxt = chr(31) + " " *indent + child.stop.text + " "
                if isinstance(child,SystemVerilogParser.Case_itemContext):
                    child.start.text = (
                        chr(31) + " " * indent + child.start.text + " "
                    )
                if isinstance(child,SystemVerilogParser.Conditional_statementContext):
                    child.start.text = (
                        chr(31) + " " * indent + child.start.text + " "
                    )
                if isinstance(child, TerminalNodeImpl) and (
                    child.symbol.text == "else"
                ):
                    child.symbol.text = (
                        chr(31) + " " * indent + child.symbol.text + " "
                    )
                elif isinstance(child, TerminalNodeImpl) and (
                    child.symbol.text == "or"
                ):
                    child.symbol.text = " " * indent + child.symbol.text + " "
                if isinstance(child,SystemVerilogParser.Simple_identifierContext):
                    child.start.text = " " + child.start.text + " "
                if isinstance(child,SystemVerilogParser.Nonblocking_assignmentContext):
                    child.start.text = (
                        chr(31) + " " * indent +child.start.text + " "
                    )
                if isinstance(child,SystemVerilogParser.Seq_blockContext):
                    child.start.text = (
                        chr(31) + " " * indent +child.start.text + " "
                    )
                    child.stop.text = chr(31) + " " * indent + child.stop.text + " "
                if isinstance(child,SystemVerilogParser.Blocking_assignmentContext):
                    child.start.text = (
                        chr(31) + " " *indent + child.start.text + " "
                    )
                if isinstance(child,SystemVerilogParser.Module_program_interface_instantiationContext):
                    child.start.text = (
                        chr(31) + " " *indent + child.start.text + " "
                    )
                self._traverse_children(child, indent +1 )
        
    def visitModule_declaration(self, ctx:SystemVerilogParser.Module_declarationContext):
        self.inst_module_node = ctx 
        self.formatProcess(self.inst_module_node)
        self.inst_module_node = parse_design_to_tree(self.text)

class InstBodyVisitor2(SystemVerilogParserVisitor):
    def __init__(self):
        self.start = None
        self.stop = None
        self.firstTerminal = False
        
    def ExtractStartAndStop(self,ctx):
        self.stop = ctx.ENDMODULE().getSymbol().start - 1
        for child in ctx.module_header().getChildren():
            if isinstance(child,TerminalNodeImpl):
                if self.firstTerminal == False:
                    self.start = child.symbol.stop + 1
                    self.firstTerminal = True
        
    def visitModule_declaration(self,ctx:SystemVerilogParser.Module_declarationContext):
        self.ExtractStartAndStop(ctx)
                    
class IdentifierVisitor(SystemVerilogParserVisitor):
    def __init__(self,cur_name_of_module_instance,top_module,design,cur_new_variable,insert_parts,cur_new_assign):
        self.start = []
        self.stop = []
        self.tmp_design = ''
        self.cur_name_of_module_instance = cur_name_of_module_instance
        self.top_module = top_module
        self.design = design
        self.cur_new_variable = cur_new_variable
        self.insert_parts = insert_parts
        self.cur_new_assign = cur_new_assign
    
    def _traverse_children(self,ctx):
        if isinstance(ctx, TerminalNodeImpl):
            pass
        else:
            for child in ctx.getChildren():
                if isinstance(child, SystemVerilogParser.Module_program_interface_instantiationContext):
                    for cur_name in self.cur_name_of_module_instance:
                        if (child.hierarchical_instance()[0].name_of_instance().getText()== cur_name):
                            self.start.append(child.start.start)
                            self.stop.append(child.stop.stop)
                self._traverse_children(child)
    
    def visitModule_declaration(self,ctx:SystemVerilogParser.Module_declarationContext):
        if ctx.module_header().module_identifier().getText() == self.top_module:
            self._traverse_children(ctx)
            self.tmp_design += self.design[ : self.start[0]]
            for i in range(0,len(self.cur_new_variable)):
                if i == 0:
                    self.tmp_design += self.cur_new_variable[i] + '\n'
                else:
                    self.tmp_design += 4*" "+self.cur_new_variable[i] + '\n'
            self.tmp_design += '\n' + 4*" "+ self.insert_parts[0][:] + '\n'
            for i in range(1,len(self.start)):
                self.tmp_design += " "*4+self.design[self.stop[i-1] + 1 : self.start[i]] + '\n'
                self.tmp_design += self.insert_parts[i] + '\n'
            for assign in self.cur_new_assign:
                self.tmp_design += " "*4+assign +'\n'
            self.tmp_design += " "*4+self.design[self.stop[-1] + 1 :] + '\n'
                                          
                   


def pyflattenverilog(design: str, top_module: str):
    tree = parse_design_to_tree(design)
    
    # Step 1. Find the top module node of the design.
    top_finder= TopModuleNodeFinder(top_module)
    top_finder.visit(tree)
    top_node_tree = top_finder.top_module_node 
    
    # Step 2: 
    visitor = MyModuleInstantiationVisitor()
    visitor.visit(top_node_tree)
    cur_module_identifier =visitor.module_identifier
    cur_name_of_module_instances = visitor.name_of_module_instances
    cur_prefixs = cur_name_of_module_instances
    cur_list_of_ports_rhs = visitor.list_of_ports_rhs
    cur_list_of_parameters = visitor.dict_of_parameters
    dict_of_lhs_to_rhs = visitor.dict_of_lhs_to_rhs
    
    
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
    
    inst_module_design_trees = []
    inst_module_nodes = []
    no_port_parameter = False
    for k in range(0,len(cur_prefixs)):
        tmp_inst_module_design = parse_design_to_tree(inst_module_design)
        visitor = RenameModuleVisitor(k,cur_prefixs,cur_module_identifier)
        visitor.visit(tmp_inst_module_design)
        inst_module_design_trees.append(tmp_inst_module_design)
        inst_module_nodes.append(visitor.inst_module_node)
        
    cur_list_of_ports_lhs = []
    cur_list_of_ports_lhs_width = []
    cur_list_of_ports_width = []
    cur_list_of_ports_direction = []
    cur_list_of_ports_type = []
    cur_list_of_data_type = []
    cur_dict_of_ports = {}

    for i in range(0, len(inst_module_design_trees)):
        visitor = InstModulePortVisitor(cur_module_identifier)
        visitor.visit(inst_module_design_trees[i])
        cur_list_of_ports_lhs = cur_list_of_ports_lhs + visitor.list_of_ports_lhs
        cur_list_of_ports_lhs_width = (
            cur_list_of_ports_lhs_width + visitor.list_of_ports_width
        )
        cur_list_of_ports_width = cur_list_of_ports_width + visitor.list_of_ports_width
        cur_list_of_ports_direction = (
            cur_list_of_ports_direction + visitor.list_of_ports_direction
        )
        cur_list_of_ports_type = cur_list_of_ports_type + visitor.list_of_ports_type
        cur_list_of_data_type = cur_list_of_data_type + visitor.list_of_data_type
        
    for i in range(0,len(cur_list_of_ports_lhs)):
        cur_dict_of_ports[cur_list_of_ports_lhs[i]] = {
            "width": cur_list_of_ports_lhs_width[i],
            "direction": cur_list_of_ports_direction[i],
            "type":cur_list_of_ports_type[i],
        }   
        
    cur_new_variable = []
    cur_new_assign = []
    
    for k in range(0,len(cur_prefixs)):
        len_instance_port = int(len(cur_list_of_ports_rhs)/len(cur_prefixs))
        ports_lhs_width = copy.deepcopy(cur_list_of_ports_lhs_width)
        
        for i in range(0,len_instance_port):
            if cur_list_of_data_type[k * len_instance_port + i]!= "":
                cur_new_variable.append(
                    cur_list_of_data_type[k * len_instance_port + i]
                    + ports_lhs_width[k * len_instance_port + i]
                    + " "
                    + cur_prefixs[k]
                    + "_"
                    + cur_list_of_ports_lhs[k * len_instance_port +i]
                    +";"
                )
            elif cur_list_of_ports_type[k * len_instance_port + i] == "reg":
                if True:
                    cur_new_variable.append(
                        "reg"
                        + ports_lhs_width[k * len_instance_port +i]
                        + " "
                        + cur_prefixs[k]
                        + "_"
                        + cur_list_of_ports_lhs[k * len_instance_port + i]
                        + ";"
                    )
            else:
                cur_new_variable.append(
                    "wire"
                    + ports_lhs_width[k *len_instance_port +i]
                    + " "
                    +cur_prefixs[k]
                    + "_"
                    + cur_list_of_ports_lhs[k * len_instance_port +i]
                    + ";"
                )
            if cur_list_of_ports_direction[k * len_instance_port + i] == "input":
                rhs = dict_of_lhs_to_rhs[cur_prefixs[k]].get(
                    cur_list_of_ports_lhs[k * len_instance_port + i]
                )
                if rhs == "":
                    continue
                if rhs is None:
                    rhs = cur_list_of_ports_rhs[k* len_instance_port +i]
                cur_new_assign.append(
                    "assign "
                    + cur_prefixs[k]
                    + "_" 
                    + cur_list_of_ports_lhs[k * len_instance_port +i]
                    + " = "
                    + rhs
                    + ";"
                )
            else:
                rhs = dict_of_lhs_to_rhs[cur_prefixs[k]].get(
                    cur_list_of_ports_lhs[k * len_instance_port + i]
                )
                if rhs == "":
                    continue
                if rhs is None:
                    rhs = cur_list_of_ports_rhs[k * len_instance_port + i]
                cur_new_assign.append(
                    "assign "
                    + rhs
                    + " = "
                    + cur_prefixs[k]
                    + "_"
                    + cur_list_of_ports_lhs[k * len_instance_port + i]
                    + ";"
                )
    inst_module_designs = []
    for k in range(0,len(cur_prefixs)):
        visitor = InstBodyVisitor()
        visitor.visit(inst_module_nodes[k])
        inst_module_nodes[k]= visitor.inst_module_node
        inst_module_designs.append(visitor.text)
        
    insert_parts = []
    for k in range (0,len(cur_prefixs)):
        visitor = InstBodyVisitor2()
        visitor.visit(inst_module_nodes[k])
        insert_parts.append(inst_module_designs[k][visitor.start : visitor.stop])
        
    visitor = IdentifierVisitor(cur_name_of_module_instance=cur_name_of_module_instances,design=design,
                                top_module = top_module, cur_new_variable=cur_new_variable,insert_parts = insert_parts,cur_new_assign=cur_new_assign)
    visitor.visit(top_node_tree)
    a = 1
   
    
    return False, visitor.tmp_design










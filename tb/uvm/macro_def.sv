// `ifndef MACRO_DEF_SVH
// `define MACRO_DEF_SVH

`define factory_create_o(_type,_name) _name = _type::type_id::create(`"_name`")
`define factory_create_c(_type,_name,_p=this) _name = _type::type_id::create(`"_name`",_p)

// `endif MACRO_DEF_SVH
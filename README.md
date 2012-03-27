# neoscout

Neoscout is a tool for verifying the schema and visualizing the structure of graph databases. It is currently geared exclusively towards neo4j but could easily be extended for other graph stores.


## Overview

neoscout walks a graph by iterating over edges and nodes (= graph element). For each visited graph element, schema properties are verified.  Depending on wether the element passes all requirements, it is considered verified or failed and counted.  Required schema properties are either set programmatically or parsed from a JSON schema file as described below.

The general programmatic use of neoscout is:

```ruby
require 'json'
require 'neoscout'

# load schema
schema_json = JOSN.parse('...schema...')
# make new scout for use with embedded neo4j database
scout = ::NeoScout::GDB_Neo4j::Scout.new
# parse schema
scout.verifier.init_from_json schema_json
# iterate over edges and nodes, collecting statistics
counts = scout.new_counts
scout.count_edges counts: counts
scout.count_nodes counts: counts
# add collected statistics back to schema_json
counts.add_to_json schema_json
# print result
puts "<<RESULT\n#{schema_json.to_json}\nRESULT"
```


## Depends on

jruby, neo4j, sinatra, json


## Installation

As a gem or via the typical bundle and rake build test install dance.


## Model

neoscout assumes that the underlying graph is directed, that nodes and edges can be assigned a unique type in the
schema, and that arbitrary properties may be assigned to each node and edge.


## JSON Schema


### Schema Format

The currently supported schema format is

```json
{
"nodes":{
    "node_type_a": {
        "properties": {
            "property_a": { "relevant": false },
            "property_b": { "relevant": true }
        }
    },
    "node_type_b": {
        "properties": {
            "property_a": { "relevant": true },
            "property_b": { "relevant": false }
         }
    }
},
"connections":{
    "edge_type_a": {
        "properties": {
            "property_a": { "relevant": false },
            "property_b": { "relevant": true }
        },
        "sources": ["node_type_a", "node_type_b"],
        "targets": ["node_type_a"]
    },
    "edge_type_b": {
        "properties": {
            "property_a": { "relevant": false },
            "property_b": { "relevant": true }
        }
    }
}
}
```

Some properties may additionally specify a value type under `type`. Verification of value types needs to be
specified programmatically.


### Schema output

When the validation has been completed, collected statistics may be appended the input JSON schema. For every collected
statistic, a counter of the form `[num_failed, num_total]` is added. The list of currently collected
statistics is:

* `nodes/type/counts` number of of nodes of type `type`
    considered ok iff all relevant node properties are verified succesfully and no additional unknown node properties
    are found or iff no node properties were specified for this type
* `connections/type/counts` number of of edges of type `type`
    verified similar to nodes
* `nodes/type/properties/prop/counts` number of properties `prop` in nodes of type `type` 
    considered ok iff the property was found and its conncrete value matched its value type (if given in the schema)
    or the property was not found and was specified as `"relevant": false`
* `connections/type/properties/prop/counts` number of properties `prop` in edges of type `type`
    verified similar to nodes
* `all/node_counts` number of nodes
    considered ok iff the node was ok according to its type
* `all/connection_counts` number of edges
    considered ok iff the node was ok according to its type

Additionally, for each edge of edge type `edge_type` it is verified, wether it's source and destination node types
`src_type` and `dst_type` are found  in `connections/type/sources` and `connections/type/targets` respectively.
Any edge type, for which these arrays are missing is considered to be verified by this test. Again, the results are
aggregated into various statistics:

* `connections/edge_type/src_stats/[ { "name": src_type, "to_dst": [ { "name": dst_type, "counts": /*count */ } ] } ]`
* `connections/edge_type/dst_stats/[ { "name": dst_type, "from_src": [ { "name": src_type, "counts": /*count */ } ] } ]`
* `nodes/src_type/src_stats/edge_type`
* `nodes/dst_type/dst_stats/edge_type`


### Optional type testing

Additionally, schema properties may have a string-valued `type` property for testing property *values.
To register a type test for property values, your implementation of `Typer` needs to mixin
`TyperValueTableMixin` (true for NeoScout::GDB_Neo4j::Typer). Then, just call:

```ruby
typer.value_type_table['string'] = lambda { |n,v| v.kind_of? String }
```

to register your type tests.  Properties that have a `type` attribute, and for which a type test is
registered but whose value fails the test are considered as failed and reported accordingly.


### Example

Please see `spec/lib/neoscout/gdb_neo4_spec.rb`, `spec/lib/neoscout/gdb_neo4_spec_schema.json`,
`spec/lib/neoscout/gdb_neo4_spec_counts.json` for an extended example.


## Standalone runner

There is a rudimentary, sinatra-based standalone runner that attaches to a local neo4j databases, and upon request
fetches a schema url and verifies the database against it. It is in `scripts/neoscout` and is installed by default.
Please consult `neoscout --help` for more details.

### Webservice API

The standalone runner can be run as a RESTful webservice using `-w`. If this is done, it suppors the
follwing API

* `/schema` retrieve schema
* `/verify` trigger verification
* `/shutdown` shutdown


## Implementation Notes

This is how things work right now but expect a major change in architecture in the next version.

`Scout` is the main class that implements the generic logic for processing nodes and edges using several
helper classes

* `Typer` assigns types to nodes and edges
* `Verifier` checks all schema properties
* `Iterator` provides iteration constructs for iterating over the nodes and edges of the underlying graph
* furthermore, `Scout` features overridable factory methods for the construction of subclasses implementing
various Constraints, most importantly the node and edge propery constraints.  Basic implementations of those
are provided in `constraints.rb`

`Counts` is used for collecting statistics and heavily tied to logic implemented by `Scout`.

JSON schema handling is in `json_schema.rb`


### Specializing for a new database

Please consult `gdb_neo4j.rb` to see how to do that, essentially you subclass `Scout` and potentially override default
values for the various member fields. The standalone runner currently is heavily tied to neo4j.


### Notes on GDB_Neo4j

* Node types are currently derived from a configurable property (defaults to '_classname')
* Edge types directly correspond to the relationship type in neo4j
* Unkown nodes/edges are assigned to a reserved `__NOTYPE__` type (the actual string may be overriden, see Typer)
* You can pass configuration options for neo4j using `-C <path-to-yml>`. This is especially important for larger
databases. See etc/neo4j.yml for an example.
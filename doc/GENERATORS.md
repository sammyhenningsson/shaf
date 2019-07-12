## Generators
Shaf ships with a couple of generators to simplify creation of new files. Each generator has an _identifier_ and they are called with `shaf generate IDENTIFIER` plus zero or more arguments.


Important: Always run `git [stash|commit]` before you generate new files. Generators may create/modify files and then delegate further work to another generator that happens to fail. In that case the generation is only partly performed and the project is in an unknown state. In such case, you would like to be able to easily restore the previous state (e.g `git checkout -- .`).

#### Scaffold
When adding a new resource its recommended to use the scaffold generator. It accepts a resource name and an arbitrary number of attribute:type arguments.
```sh
shaf generate scaffold some_resource attr1:string attr2:integer
```
The scaffold generator will call the model generator and the controller generator, see below.

#### Controller
A new controller is generated with the _controller_ identifier, a resource name and an arbitrary number of attribute:type arguments.
```sh
shaf generate controller some_resource attr1:string attr2:integer
```
This will add a new controller and an integration spec. It will also modify the root resource to include a link the the collection endpoint for _some_resource_.

#### Model
A new model is generated with the _model_ identifier, a resource name and an arbitrary number of attribute:type arguments.
```sh
shaf generate model some_resource attr1:string attr2:integer
```
This will add a new model, call the serializer generator and generate a new db migration to created a new table.

#### Serializer
A new serializer is generated with the _serializer_ identifier, a resource name and an arbitrary number of attribute arguments.
```sh
shaf generate serializer some_resource attr1 attr2
```
This will add a new serializer, a serializer spec and call the policy generator.

#### Policy
A new policy is generated with the _policy_ identifier, a resource name and an arbitrary number of attribute arguments.
```sh
shaf generate policy some_resource attr1 attr2
```
This will add a new policy.

#### Migration
Shaf currently supports 5 db migrations to be generated plus the possibility to generate an empty migration. These are:
```sh
  generate migration [name]
  generate migration add column TABLE_NAME field:type
  generate migration add index TABLE_NAME COLUMN_NAME
  generate migration create table TABLE_NAME [field:type] [..]
  generate migration drop column TABLE_NAME COLUMN_NAME
  generate migration rename column TABLE_NAME OLD_NAME NEW_NAME
```
The `field` parameter is the name of the column (to be added resp. altered). The `type` parameter specifies the type that the column should have. The following types are supported:
 - `integer`        => `Integer`
 - `varchar`        => `String`
 - `string`         => `String`
 - `text`           => `String (`text: true`)
 - `blob`           => `File`
 - `bigint`         => `Bignum`
 - `double`         => `Float`
 - `numeric`        => `BigDecimal`
 - `date`           => `Date`
 - `timestamp`      => `DateTime`
 - `time`           => `Time`
 - `bool`           => `TrueClass`
 - `boolean`        => `TrueClass`
 - `index`          => `index` (`unique: true`)
 - `foreign_key`    => `Integer`

The foreign_key type requires that the referenced table is given. This is done by adding a comma, `,` and the table name. Like:
```
shaf generate scaffold post user_id:foreign_key,users
```

See [the Sequel migrations documentation](http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html) for more info.
Note: You can also add custom migrations, see [Customizations](CUSTOMIZATIONS.md)

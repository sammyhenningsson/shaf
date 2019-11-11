## Customizations
#### Commands
Currently Shaf support the following commands (`new`, `server`, `test`, `console`, `generate`, `upgrade` and `version`). It's also possible to extend Shaf with custom commands and generators. Whenever the `shaf` command is executed the file `config/customize.rb` is loaded and checked for additional commands. To add a custom command, create a class that inherits from `Shaf::Command::Base`. Either put it directly in `config/customize.rb` or put it in a separate file and require that file inside `config/customize.rb`. Your customized class must call the inherited class method `identifier` with a `String`/`Symbol`/`Regexp` (or an array of `String`/`Symbol`/`Regexp` values) that _identifies_ the command. The identifier is used to match arguments passed to `shaf`. The command/generator must respond to `call` without any arguments. The arguments after the identifer will be availble from the instance method `args`. Writing a couple of simple commands that echos back the arguments would be written as:
```ruby
class EchoCommand < Shaf::Command::Base
  identifier :echo

  def call
    puts args
  end
end

class EchoUpCommand < Shaf::Command::Base
  identifier :echo, :up

  def call
    puts args.map(&:upcase)
  end
end

class EchoDownCommand < Shaf::Command::Base
  identifier :echo, :down

  def call
    puts args.map(&:downcase)
  end
end
```
Then running `shaf echo Hello World` would print:
```sh
Hello
World
```
Running `shaf echo up Hello World` would print:
```sh
HELLO
WORLD
```
Running `shaf echo down Hello World` would print:
```sh
hello
world
```
These commands are of course useless, but hopefully they give you an idea of what is happening.  

#### Generators
Generators work pretty much the same as commands, but they MUST inherit from `Shaf::Generator::Base`. Generators also inherits the following instance methods that may help generating files processed through erb:
- `template_dir`
- `read_template(file, directory = nil)`
- `render(template, locals = {})`
- `write_output(file, content)`  

Example:
```ruby
class FooServiceGenerator < Shaf::Generator::Base
  identifier :foo

  def template_dir
    "generator_templates"
  end

  def call
    content = render("foo_service", {some_variables: "used_in_template"})
    write_output("api/services/foo_service.rb", content)
  end
end
```
This would require the file `generator_templates/foo_service.erb` to exist in the project root. Executing `shaf generate foo` would then read that template, process it through erb (utilizing any local variables given to `render`) and then create the output file `api/services/foo_service.rb`.

#### Responders
When `#respond_with` is used, the serialization is delegated to the best matching `Responder`. Each `Responder` manages a specific media type. Thus the "best" `Responder` is the one that best matches the request's `Accept` header.
Shaf ships with three responders. They support the mediatypes `application/hal+json`, `application/problem+json` and `text/html`. (If the `Accept` header does not match any of those, the default response format will be `application/hal+json`).  
Each responder is a subclass of `Shaf::Responder::Base`. To add more responders, simply define new subclasses of `Shaf::Responder::Base`.  
All responders must implement `#body` and the must call `::mime_type(key, mime_type)` (where `key` is `Symbol` and `mime_type` is a `String`).  
`#body` must return the serialized response.
Responders are instantiated with `new(controller, resource, **options)` and they have `attr_readers` for each of those arguments.  
Responders may override `::can_handle?(resource)`, which is used to decide with or not a responder is able to process a given object.  
Say that you would like to be able to return siren payloads. And you happen to have a `MyCustomSirenSerializer` class that can turn any object into a proper siren payload. Then adding a Siren responder would look like this.
```ruby
class SirenResponder < Shaf::Responder::Base
  mime_type :siren, 'application/vnd.siren+json'

  def body
    MyCustomSirenSerializer.call(resource)
  end
end
```

Then, when your controller actions are using `respond_with some_resource_object`. Your client's will be able to choose if they would like the response to be formatted as `application/hal+json` or `application/vnd.siren+json` (by setting the `Accept` header correspondingly).

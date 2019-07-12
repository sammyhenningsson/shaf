## Customizations
Currently Shaf support the following commands (`new`, `server`, `test`, `console`, `generate`, `upgrade` and `version`). It's also possible to extend Shaf with custom commands and generators. Whenever the `shaf` command is executed the file `config/customize.rb` is loaded and checked for additional commands. To add a custom command, create a class that inherits from `Shaf::Command::Base`. Either put it directly in `config/customize.rb` or put it in a separate file and require that file inside `config/customize.rb`. Your customized class must call the inherited class method `identifier` with a `String`/`Symbol`/`Regexp` (or an array of `String`/`Symbol`/`Regexp` values) that _identifies_ the command. The identifier is used to match arguments passed to `shaf`. The command/generator must respond to `call` without any arguments. The arguments after the identifer will be availble from the instance method `args`. Writing a couple of simple commands that echos back the arguments would be written as:
```sh
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
Generators work pretty much the same but they MUST inherit from `Shaf::Generator::Base`. Generators also inherits the following instance methods that may help generating files processed through erb:
- `template_dir`
- `read_template(file, directory = nil)`
- `render(template, locals = {})`
- `write_output(file, content)`  

Example:
```sh
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


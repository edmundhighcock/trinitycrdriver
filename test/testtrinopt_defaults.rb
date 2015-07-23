@output = :pfus
@search=  {chease: {elong: [1.35, 0.2], triang: [0.0, 0.1]}}
@trinity_defaults = 'trinity_trinopt'
@gs_defaults = 'chease_trinopt'
@chease_exec = `which chease`.chomp
if not @chease_exec =~ /chease$/
  raise "Can't find chease executable in path!"
end
@nit = 2

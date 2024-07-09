using Documenter, Madagascar

man_path = "$(ENV["RSFROOT"])/share/man/man1"
filenames = read(`ls "$(man_path)"`, String)
filenames = split(filenames, '\n')
filenames = filter(x -> endswith(x, ".1"), filenames)

out_file = open("docs/gen_docs.sh", "w")
pfile = x -> println(out_file, x)
pfile("#!/bin/bash")
pfile("rm -rf docs/libdoc")
pfile("mkdir -p docs/libdoc/misc")
for letter in 'a':'z'
    pfile("mkdir -p docs/libdoc/$(letter)")
end

for filename in filenames
    println(filename)
    third_char = filename[3]
    if third_char in 'a':'z'
        pfile("ln -s $man_path/$filename docs/libdoc/$third_char/$filename")
    else
        pfile("ln -s $man_path/$filename docs/libdoc/misc/$filename")
    end
end
close(out_file)
run(`chmod +x docs/gen_docs.sh`)
run(`./docs/gen_docs.sh`)

makedocs(
    sitename="Madagascar julia wrapper",
    doctest=false,
    clean=true,
    authors="Mathias Louboutin",
    pages=Any["Home"=>"index.md"],
)

deploydocs(repo="github.com/tmasthay/Madagascar.jl", devbranch="main")

// Run this code at the debug console in Google Chrome or other compatible browser
// at https://juliapackages.com/packages?sort=stars to get the lists of packages
// that appear inside the dropdown boxes of the julia.ipynb and julia-gpu.ipynb

items = [...document.getElementsByClassName("text-md leading-5 text-heavy text-indigo-600 truncate")].
  slice(0, 256).
  map(x=>x.innerText.replace(".jl","")).
  filter(x=>x!="IJulia")

items_gpu = [...items].
  filter(x=>!x.startsWith("CUDA"))
items_gpu_spec = [...items].
  filter(x=>x.startsWith("CUDA"))

function get_list(a, s, e) {
  return a.
    map(x=>'\\"'+x+'\\"').
    slice(s, e).
    sort()
}

str_items = [...get_list(items, 0, 16), ...get_list(items, 16)].
    join(", ")

str_items_gpu = [...get_list(items_gpu_spec, 0), ...get_list(items_gpu, 0, 16), ...get_list(items_gpu, 16)].
    join(", ")


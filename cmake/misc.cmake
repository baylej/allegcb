#-----------------------------------------------------------------------------#
#
# Functions for CMake :
#     Append deps to the ${link_libs}
#     Generating lib filenames
# 
#-----------------------------------------------------------------------------#

# first var is out, second is in
function(append_deps _deps_list deps_list)
set(var ${deps_list})
if(CMAKE_SYSTEM_NAME MATCHES "Windows")
	# cmake will add '.a' or '.lib' itself ?
	list(APPEND var
		shlwapi
		psapi
		winmm
		opengl32
		Gdiplus)
	if(ALLEGRO_STATICLINK)
		#todo link with static zlib, vorbis, ogg, ...
	endif(ALLEGRO_STATICLINK)
endif(CMAKE_SYSTEM_NAME MATCHES "Windows")
set(${_deps_list} ${var} PARENT_SCOPE)
endfunction(append_deps)

# make_libs_filenames(OUT_VAR ALLEGRO_VERSION)
# OUT_VAR is out and must be empty !
# ALLEGRO_VERSION can be "5.0.7"
# This function assumes filenames were make by allegro's cmake
function(make_libs_filenames _deps_list al_ver)
set(var "")
set(tmp "")
# on linux/darwin we need extra obj deps only if you build statically
if(NOT WIN32 AND ALLEGRO_STATICLINK)
	set(var
		allegro-static
		allegro_image-static
		allegro_font-static
		allegro_memfile-static
		allegro_physfs-static
		allegro_acodec-static
		allegro_audio-static)
	
	if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
		list(APPEND var allegro_main-static)
	endif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
	set(${_deps_list} ${var} PARENT_SCOPE)
	return()
endif(NOT WIN32 AND ALLEGRO_STATICLINK)

if(ALLEGRO_LINK_MONOLITH)
	set(var allegro-${al_ver}-monolith)
else(ALLEGRO_LINK_MONOLITH)
	set(var
		allegro-${al_ver} 
		allegro_image-${al_ver}
		allegro_font-${al_ver}
		allegro_memfile-${al_ver}
		allegro_physfs-${al_ver}
		allegro_acodec-${al_ver}
		allegro_audio-${al_ver})
endif(ALLEGRO_LINK_MONOLITH)

# appends -static
if(ALLEGRO_STATICLINK)
	foreach(filename ${var})
		list(APPEND tmp "${filename}-static")
	endforeach(filename)
	set(var ${tmp})
	set(tmp "")
endif(ALLEGRO_STATICLINK)

# appends -mt or -md
if(ALLEGRO_LINK_MT)
	foreach(filename ${var})
		list(APPEND tmp "${filename}-mt")
	endforeach(filename)
else(ALLEGRO_LINK_MT)
	foreach(filename ${var})
		list(APPEND tmp "${filename}-md")
	endforeach(filename)
endif(ALLEGRO_LINK_MT)
set(var ${tmp})
set(tmp "")

# appends -debug
if(ALLEGRO_LINK_DBG)
	foreach(filename ${var})
		list(APPEND tmp "${filename}-debug")
	endforeach(filename)
	set(var ${tmp})
endif(ALLEGRO_LINK_DBG)
set(${_deps_list} ${var} PARENT_SCOPE)
endfunction(make_libs_filenames)

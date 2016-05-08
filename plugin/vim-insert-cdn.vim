" Get cdn url for specified package name and version
function! GetCdnUrl(name, version)
	let api_url = 'http://api.jsdelivr.com/v1/jsdelivr/libraries/' . a:name . '/' . a:version . '\?fields\=mainfile'
	" awk command for extracting mainfile and removing double quotes from it
	let awk_get_filename = '{gsub("\"", "", $2); print $2}'
	let awk_get_first_line = 'END{print}'
	let greps = "grep .min | grep -v .map"

	let cmd = "curl -s " . api_url . " | /usr/bin/env sh JSON.sh -b | awk '" . awk_get_filename . "'" . " | " . greps
	
	" get json from api with curl, parse it and extract mainfile field
	if (a:version != '')
		let mainfile = system(cmd . " | awk '" . awk_get_first_line . "'")
		let ver = a:version
	else
		let mainfile = system(cmd)
		let ver = 'latest'
	endif

	let error_message = "Cannot found js library with name " . a:name . " and " . ver . " version"
	if (mainfile == '')
		echo error_message
		return ''
	endif

	return 'https://cdn.jsdelivr.net/' . a:name . '/' . ver . '/' . mainfile
endfunction

" Insert script tag with cdn url under cursor position
function! InsertScriptTag(vname)
	let vname = split(a:vname, '@')
	if (len(vname) == 2)
		let ver = vname[1]
	else
		let ver = ''
	endif
	let name = vname[0]
	let url = substitute(GetCdnUrl(name, ver), '\n\+$', '', '')
	if (url != '')
		let script_tag = '<script type="text/javascript" src="' . url . '"></script>'
		:put =script_tag
	endif
endfunction

command! -nargs=1 InsertScriptTag call InsertScriptTag(<f-args>)

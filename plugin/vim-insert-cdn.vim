" Get cdn url for specified package name and version
function! GetCdnUrl(name, version)
	let api_url = 'https://jsdelivr-api.herokuapp.com/v2/jsdelivr/library/' . a:name

	" parse json command
	let parse_json = "/usr/bin/env sh JSON.sh -b"
	
	" awk command for extracting mainfile and removing double quotes from it
	let awk_get_filename = '{gsub("\"", "", $2); print $2}'

	" awk command to get first and last line of input
	let awk_get_first_and_last_line = 'NR==1;END{print}'

	" command to get parsed json from url
	let get_json_cmd = "curl -s " .
		\api_url .
		\" | " . parse_json

	" store parsed json in variable
	let parsed_json = system(get_json_cmd)

	" if version of package is not specified, we get the latest version from
	" parsed json (latest version is first in the array of versions)
	if (a:version == '')
		let grep_versions = 'grep \"versions\",0'
		let get_version_cmd = "echo '" . parsed_json . "' | " . grep_versions . " | awk '" . awk_get_filename . "'"
		" remove new lines from version
		let ver = substitute(system(get_version_cmd), '\n\+', '', '')
	else
		let ver = a:version
	endif

	" if no version found, return nothing
	if (ver == '')
		echo "Cannot found js library with name " . a:name . " and latest version"
		return ''
	endif

	let grep = 'grep \"assets\",\"' . ver . '\"'
	let cmd =
		\"echo '" . parsed_json .
		\"' | " . grep .
		\" | awk '" .
		\awk_get_filename .
		\"' | awk '" .
		\awk_get_first_and_last_line .
		\"'"

	" get json from api with curl, parse it and extract baseUrl and mainfile field
	let data = system(cmd)

	let error_message = "Cannot found js library with name " . a:name . " and " . ver . " version"
	if (len(data) == 1 || len(data) == 0)
		echo error_message
		return ''
	endif

	" split resulting data by new line
	" first line contains baseUrl, second contains mainfile
	let arr = split(data, '\n')
	let url = arr[0] . arr[1]
	return url
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

	" remove new lines from returned url, if any
	let url = substitute(GetCdnUrl(name, ver), '\n\+$', '', '')
	if (url != '')
		let script_tag = '<script type="text/javascript" src="' . url . '"></script>'
		:put =script_tag
	endif
endfunction


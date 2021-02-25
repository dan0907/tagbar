let s:visibility_symbols = {
    \ 'public'    : '+',
    \ 'protected' : '#',
    \ 'private'   : '-'
\ }
if exists('g:tagbar_visibility_symbols') && !empty(g:tagbar_visibility_symbols)
    let s:visibility_symbols = g:tagbar_visibility_symbols
endif

function! tagbar#prototypes#basetag#new(name) abort
    let newobj = {}

    let newobj.name          = a:name
    let newobj.fields        = {}
    let newobj.fields.line   = 0
    let newobj.fields.column = 0
    let newobj.fields.end    = 0
    let newobj.prototype     = ''
    let newobj.data_type     = ''
    let newobj.path          = ''
    let newobj.fullpath      = a:name
    let newobj.fullname      = a:name
    let newobj.qualifiedname = a:name
    let newobj.depth         = 0
    let newobj.parent        = {}
    let newobj.tline         = -1
    let newobj.fileinfo      = {}
    let newobj.typeinfo      = {}
    let newobj._childlist    = []
    let newobj._childdict    = {}
    let newobj.scopestr      = ''
    let newobj.scopedenum    = 0

    if a:name =~# '^__anon'
        let newobj.displayname = '__unnamed__'
        let newobj.unnamed     = 1
    else
        if a:name =~# '^operator\s\+\W'
            let newobj.displayname = substitute(a:name, '^operator\zs\s\+', '', '')
        else
            let newobj.displayname = a:name
        endif
        let newobj.unnamed = 0
    endif

    let newobj.isNormalTag = function(s:add_snr('s:isNormalTag'))
    let newobj.isPseudoTag = function(s:add_snr('s:isPseudoTag'))
    let newobj.isSplitTag = function(s:add_snr('s:isSplitTag'))
    let newobj.isKindheader = function(s:add_snr('s:isKindheader'))
    let newobj.getPrototype = function(s:add_snr('s:getPrototype'))
    let newobj.getDataType = function(s:add_snr('s:getDataType'))
    let newobj._getPrefix = function(s:add_snr('s:_getPrefix'))
    let newobj.initFoldState = function(s:add_snr('s:initFoldState'))
    let newobj.getClosedParent = function(s:add_snr('s:getClosedParent'))
    let newobj.isFoldable = function(s:add_snr('s:isFoldable'))
    let newobj.isFolded = function(s:add_snr('s:isFolded'))
    let newobj.openFold = function(s:add_snr('s:openFold'))
    let newobj.closeFold = function(s:add_snr('s:closeFold'))
    let newobj.setFolded = function(s:add_snr('s:setFolded'))
    let newobj.openParents = function(s:add_snr('s:openParents'))
    let newobj.addChild = function(s:add_snr('s:addChild'))
    let newobj.getChildren = function(s:add_snr('s:getChildren'))
    let newobj.getChildrenByName = function(s:add_snr('s:getChildrenByName'))
    let newobj.removeChild = function(s:add_snr('s:removeChild'))
    let newobj.initQualifiedName = function(s:add_snr('s:initQualifiedName'))

    return newobj
endfunction

" s:isNormalTag() {{{1
function! s:isNormalTag() abort dict
    return 0
endfunction

" s:isPseudoTag() {{{1
function! s:isPseudoTag() abort dict
    return 0
endfunction

" s:isSplitTag {{{1
function! s:isSplitTag() abort dict
    return 0
endfunction

" s:isKindheader() {{{1
function! s:isKindheader() abort dict
    return 0
endfunction

" s:getPrototype() {{{1
function! s:getPrototype(short) abort dict
    return self.prototype
endfunction

" s:getDataType() {{{1
function! s:getDataType() abort dict
    return self.data_type
endfunction

" s:_getPrefix() {{{1
function! s:_getPrefix() abort dict
    let fileinfo = self.fileinfo

    if !empty(self._childlist)
        if fileinfo.tagfolds[self.fields.kind][self.fullname]
            let prefix = g:tagbar#icon_closed
        else
            let prefix = g:tagbar#icon_open
        endif
    else
        let prefix = ' '
    endif
    " Visibility is called 'access' in the ctags output
    if g:tagbar_show_visibility
        if has_key(self.fields, 'access')
            let prefix .= get(s:visibility_symbols, self.fields.access, ' ')
        else
            let prefix .= ' '
        endif
    endif

    return prefix
endfunction


" s:initQualifiedName() {{{1
function! s:initQualifiedName(unnamedtypedict) abort dict
    let parent = self.parent
    while !empty(parent)
          \ && (parent.fields.kind ==# 'g' && !parent.scopedenum
          \ || parent.fields.kind ==# 'u' && parent.unnamed && !has_key(a:unnamedtypedict, parent.name))
        let parent = parent.parent
    endwhile
    if !empty(parent)
        if parent.fields.kind ==# 'f'
            let self.qualifiedname = self.displayname
        else
            let self.qualifiedname = parent.qualifiedname . self.typeinfo.sro . self.displayname
        endif
    else
        if self.fields.kind ==# 'd'
            let self.qualifiedname = self.displayname
        else
            let self.qualifiedname = self.typeinfo.sro . self.displayname
        endif
    endif
    for child in self._childlist
        call child.initQualifiedName(a:unnamedtypedict)
    endfor
endfunction

" s:initFoldState() {{{1
function! s:initFoldState(known_files) abort dict
    let fileinfo = self.fileinfo

    let parent = self.parent
    if !empty(parent)
        let self.fullname = parent.fullname . self.typeinfo.sro . self.name
    else
        let self.fullname = self.fullpath
    endif

    if has_key(self.fields, 'signature')
        let self.fullname .= self.fields.signature
    endif

    if a:known_files.has(fileinfo.fpath) &&
     \ has_key(fileinfo, '_tagfolds_old') &&
     \ has_key(fileinfo._tagfolds_old[self.fields.kind], self.fullname)
        " The file has been updated and the tag was there before, so copy its
        " old fold state
        let fileinfo.tagfolds[self.fields.kind][self.fullname] =
                    \ fileinfo._tagfolds_old[self.fields.kind][self.fullname]
    elseif self.fields.kind ==# 'f' || self.depth >= fileinfo.foldlevel
        let fileinfo.tagfolds[self.fields.kind][self.fullname] = 1
    else
        let fileinfo.tagfolds[self.fields.kind][self.fullname] =
                    \ fileinfo.kindfolds[self.fields.kind]
    endif
endfunction

" s:getClosedParentTline() {{{1
function! s:getClosedParent() abort dict
    let tag  = self

    " Find the first closed parent, starting from the top of the hierarchy.
    let parents   = []
    let curparent = self.parent
    while !empty(curparent)
        call add(parents, curparent)
        let curparent = curparent.parent
    endwhile
    for parent in reverse(parents)
        if parent.isFolded()
            let tag = parent
            break
        endif
    endfor

    return tag
endfunction

" s:isFoldable() {{{1
function! s:isFoldable() abort dict
    return !empty(self._childlist)
endfunction

" s:isFolded() {{{1
function! s:isFolded() abort dict
    return self.fileinfo.tagfolds[self.fields.kind][self.fullname]
endfunction

" s:openFold() {{{1
function! s:openFold() abort dict
    if self.isFoldable()
        let self.fileinfo.tagfolds[self.fields.kind][self.fullname] = 0
    endif
endfunction

" s:closeFold() {{{1
function! s:closeFold() abort dict
    let newline = line('.')

    if self.isFoldable() && !self.isFolded()
        " Tag is parent of a scope and is not folded
        let self.fileinfo.tagfolds[self.fields.kind][self.fullname] = 1
        let newline = self.tline
    elseif !empty(self.parent)
        " Tag is normal child, so close parent
        let parent = self.parent
        let self.fileinfo.tagfolds[parent.fields.kind][parent.fullname] = 1
        let newline = parent.tline
    endif

    return newline
endfunction

" s:setFolded() {{{1
function! s:setFolded(folded) abort dict
    let self.fileinfo.tagfolds[self.fields.kind][self.fullname] = a:folded
endfunction

" s:openParents() {{{1
function! s:openParents() abort dict
    let parent = self.parent

    while !empty(parent)
        call parent.openFold()
        let parent = parent.parent
    endwhile
endfunction

" s:addChild() {{{1
function! s:addChild(tag) abort dict
    call add(self._childlist, a:tag)

    if has_key(self._childdict, a:tag.name)
        call add(self._childdict[a:tag.name], a:tag)
    else
        let self._childdict[a:tag.name] = [a:tag]
    endif
endfunction

" s:getChildren() {{{1
function! s:getChildren() dict abort
    return self._childlist
endfunction

" s:getChildrenByName() {{{1
function! s:getChildrenByName(tagname) dict abort
    return get(self._childdict, a:tagname, [])
endfunction

" s:removeChild() {{{1
function! s:removeChild(tag) dict abort
    let idx = index(self._childlist, a:tag)
    if idx >= 0
        call remove(self._childlist, idx)
    endif

    let namelist = get(self._childdict, a:tag.name, [])
    let idx = index(namelist, a:tag)
    if idx >= 0
        call remove(namelist, idx)
    endif
endfunction

" s:add_snr() {{{1
function! s:add_snr(funcname) abort
    if !exists('s:snr')
        let s:snr = matchstr(expand('<sfile>'), '<SNR>\d\+_\zeget_snr$')
    endif
    return s:snr . a:funcname
endfunction

" Modeline {{{1
" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1

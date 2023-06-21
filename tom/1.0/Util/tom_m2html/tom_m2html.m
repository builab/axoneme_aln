function tom_m2html(varargin)
%Creates documention HTML-Files for the TOM Toolbox help files. 
%
%SYNTAX
%tom_m2html('mfiles',Value1,'htmldir',Value2,'categorie',Value3,'verbose','on')
%
%DESCRIPTION
%Generates an HTML documentation of the Matlab M-file Value1. The HTML file is 
%written in a directory Value2. The M-file belongs to the TOM Toolbox categorie
%Value3. The optional value for verbose mode is on.
%Launch TOM_M2HTML one directory above the directory your wanting to generate
%documentation for.
%
%Lists property input:
%   mFiles    :Value1 (string) defines the name of the M-file for which an HTML 
%              documentation will be built.
%   htmlDir   :Value2 (string) defines the top level directory for generated
%              HTML files [ 'doc' ]
%   categorie :Value3 (string) defines the name of the correct TOM categorie
%               - Acquisition
%               - Analysis
%               - Average
%               - Display
%               - Filtrans (Filtering and Transformation)
%               - Geom (Geometrical shapes)
%               - IOfun (input/Output)
%               - Misc (Miscellaneous)
%               - Reconstruction
%               - Sptrans (Spatial transformation)
%               - Util (Utilities)
%   verbose   : Verbose mode [ {on} | off ]
%
%Output
%   HTML file is created
%
%EXAMPLE
%   Matlab current directory: C:\Program Files\MATLAB704\work
%   Folder containing tom_mrc2em.m: C:\Program Files\MATLAB704\work
%   tom_m2html('mfiles','tom_mrc2em.m','htmldir','..\Doc','categorie','IOfun')
%
%   tom_mrc2em.html will be in C:\Program Files\MATLAB704\Doc
%
%   Note 
%   After the categorie SEE ALSO of the m file 'tom_mrc2em.m', there
%   should have 2 arguments separated by a comma. In the case where there
%   is just one, please a comma after the argument
%   e.g.: SEE ALSO
%         TOM_MRCREAD,
%
%   edit the HTML file with a HTML editor. Check all the hyperlinks
%   (arrows, see also). Some mistakes can occurs especially with tables.
%
%SEE ALSO
% TEMPLATE,
%
%  Copyright (c) 2004
%  TOM toolbox for Electron Tomography
%  Max-Planck-Institute for Biochemistry
%  Dept. Molecular Structural Biology
%  82152 Martinsried, Germany
%  http://www.biochem.mpg.de/tom
%
%Created 05/04/05
%

%  Thanks to Guillaume Flandin <Guillaume@artefact.tk>. His function called
%  M2HTML is modified to be adapted to the TOM Toolbox. See M2HTML for more
%  information. Download M2HTML directly from Mathworks webpage
%  <http://www.mathworks.com/matlabcentral/fileexchange/loadCategory.do>
%


%-------------------------------------------------------------------------------
%- Set up options and default parameters
%-------------------------------------------------------------------------------
t0 = clock; % for statistics
msgInvalidPair = 'Bad value for argument: ''%s''';

options = struct('verbose', 1,...
                 'mFiles', {{'.'}},...
                 'categorie',{{'.'}},...
				 'htmlDir', 'doc',...
				 'template', '',...
                 'extension', '.html',...
                 'source', 1');

if nargin == 1 & isstruct(varargin{1})
	paramlist = [ fieldnames(varargin{1}) ...
				  struct2cell(varargin{1}) ]';
	paramlist = { paramlist{:} };
else
	if mod(nargin,2)
		error('Invalid parameter/value pair arguments.');
	end
	paramlist = varargin;
end

optionsnames = lower(fieldnames(options));
for i=1:2:length(paramlist)
	pname = paramlist{i};
	pvalue = paramlist{i+1};
	ind = strmatch(lower(pname),optionsnames);
	if isempty(ind)
		error(['Invalid parameter: ''' pname '''.']);
	elseif length(ind) > 1
		error(['Ambiguous parameter: ''' pname '''.']);
	end
	switch(optionsnames{ind})
		case 'mfiles'
			if iscellstr(pvalue)
				options.mFiles = pvalue;
			elseif ischar(pvalue)
				options.mFiles = cellstr(pvalue);
			else
				error(sprintf(msgInvalidPair,pname));
			end
			options.load = 0;
		case 'htmldir'
			if ischar(pvalue)
				if isempty(pvalue),
					options.htmlDir = '.';
				else
					options.htmlDir = pvalue;
				end
			else
				error(sprintf(msgInvalidPair,pname));
			end
        case 'categorie'
			if ischar(pvalue)
				if isempty(pvalue),
					options.categorie = '.';
				else
					options.categorie = pvalue;
				end
			else
				error(sprintf(msgInvalidPair,pname));
			end
		case 'verbose'
			if strcmpi(pvalue,'on')
				options.verbose = 1;
			elseif strcmpi(pvalue,'off')
				options.verbose = 0;
			else
				error(sprintf(msgInvalidPair,pname));
			end            
		otherwise
			error(['Invalid parameter: ''' pname '''.']);
	end
end

%-------------------------------------------------------------------------------
%- Get template files location
%-------------------------------------------------------------------------------
s = fileparts(which(mfilename));
options.template = fullfile(s,'templates',options.template);
if exist(options.template) ~= 7
	error('[Template] Unknown template.');
end

%-------------------------------------------------------------------------------
%- Get the M-files
%-------------------------------------------------------------------------------
if strcmp(options.mFiles,'.')
    d = dir(pwd); d = {d([d.isdir]).name};
    options.mFiles = {d{~ismember(d,{'.' '..'})}};
end
mfiles = getmfiles(options.mFiles,{});
if ~length(mfiles), fprintf('Nothing to be done.\n'); return; end
if options.verbose,
    fprintf('Found %d M-files.\n',length(mfiles));
end
%-------------------------------------------------------------------------------
%- Get list of (unique) directories and (unique) names
%-------------------------------------------------------------------------------
if ~options.load
	mdirs = {};
	names = {};
	for i=1:length(mfiles)
		[mdirs{i}, names{i}] = fileparts(mfiles{i});
		if isempty(mdirs{i}), mdirs{i} = '.'; end
    end
	mdir = unique(mdirs);
	if options.verbose,
		fprintf('Found %d unique Matlab directories.\n',length(mdir));
    end
	name = names;
end

%-------------------------------------------------------------------------------
%- Create output directory, if necessary
%-------------------------------------------------------------------------------
if isempty(dir(options.htmlDir))										       
	%- Create the top level output directory							       
	if options.verbose  												       
		fprintf('Creating directory %s...\n',options.htmlDir);  		       
    end 																       
	if options.htmlDir(end) == filesep, 								       
		options.htmlDir(end) = [];  									       
	end 																       
	[pathdir, namedir] = fileparts(options.htmlDir);					       
	if isempty(pathdir) 												       
		[status, msg] = mkdir(escapeblank(namedir)); 								       
	else																       
		[status, msg] = mkdir(escapeblank(pathdir), escapeblank(namedir));						       
	end 																       
	if ~status, error(msg); end 														       
end 																	       

%-------------------------------------------------------------------------------
%- Get H1 line, syntax, description, example, see also
%-------------------------------------------------------------------------------
if ~options.load
    syntax     = cell(size(mfiles));
	h1line     = cell(size(mfiles));
    syntax     = cell(size(mfiles));
    description= '';
    example    = '';
    seealso    = '';
	%for i=1:length(mfiles)
		if options.verbose
			fprintf('Processing file %s...',mfiles{i});
        end
		s = mfileparse(mfiles{i}, mdirs, names, options);
        
        syntax{i}      = s.syntax;
        description    = s.description;
        example        = s.example;
        seealso        = s.seealso;
		h1line{i}      = s.h1line;
		if options.verbose, fprintf('\n'); end
        %end
end


%-------------------------------------------------------------------------------
%- Setup the output directories
%-------------------------------------------------------------------------------
for i=1:length(mdir)
	if exist(fullfile(options.htmlDir,mdir{i})) ~= 7
		ldir = splitpath(mdir{i});
		for j=1:length(ldir)
			if exist(fullfile(options.htmlDir,ldir{1:j})) ~= 7
				%- Create the output directory
				if options.verbose
					fprintf('Creating directory %s...\n',...
							fullfile(options.htmlDir,ldir{1:j}));
				end
				if j == 1
					[status, msg] = mkdir(escapeblank(options.htmlDir), ...
						escapeblank(ldir{1}));
				else
					[status, msg] = mkdir(escapeblank(options.htmlDir), ...
						escapeblank(fullfile(ldir{1:j})));
				end
				error(msg);
			end
		end
	end
end
%--------------------------------------------------------------------------
%- Define hyperlink for previous and next file
%--------------------------------------------------------------------------
d=dir('*.m');
dd=struct2cell(d);
file=dd(1,1:size(dd,2));
for i=1:size(file,2)
    if findstr(name{1},file{i})
        if (i-1)==0
            pn='..\';
        else
            pn=file{i-1};
        end
        if (i+1)>size(file,2)
            nn='..\';
        else
            nn=file{i+1};
        end
        qwe=findstr(pn,'.');
        if ~isempty(qwe)            
            prev_html=[pn(1:qwe) 'html'];
            prev_name=[pn(1:qwe-1)];
        else
            prev_html=[prev_name(1:qwe) '.html'];
            prev_name=pn;
        end
        qwe=findstr(nn,'.');
        if ~isempty(qwe)            
            next_html=[nn(1:qwe) 'html'];
            next_name=[nn(1:qwe-1)];         
        else
            next_html=[nn(1:qwe) '.html'];
            next_name=pn;
        end
        break;
    end
end

%--------------------------------------------------------------------------
%- Define hyperlink for see also
%--------------------------------------------------------------------------
koma=findstr(',',s.seealso);
if (~isempty(s.seealso)) & (isempty(koma))
    koma=[1 1];
end
lihyp='';hyplpath='';hy='';
if ~isempty(koma)
    for i=1:size(koma,2)+1
        if (i-1)==0        
            lihyp=[lihyp;cellstr(fliplr(deblank(fliplr(deblank(s.seealso(1:koma(i)-1))))))];
        elseif (i~=0)|(i<size(koma,2))
            if i==size(koma,2)+1
                lihyp=[lihyp;cellstr(fliplr(deblank(fliplr(deblank(s.seealso(koma(i-1)+1:end))))))];
            else
                lihyp=[lihyp;cellstr(fliplr(deblank(fliplr(deblank(s.seealso(koma(i-1)+1:koma(i)-1))))))];          
            end        
        end
    end
    %lihyp
    for i=1:size(lihyp,1)    
        a=which(lihyp{i});
        if ~isempty(findstr('acquisition',a))
            a=regexprep(a,'acquisition','Acquisition');
        elseif ~isempty(findstr('analysis',a))
            a=regexprep(a,'analysis','Analysis');
        elseif ~isempty(findstr('average',a))
            a=regexprep(a,'average','Average');
        elseif ~isempty(findstr('average',a))
            a=regexprep(a,'average','Average');       
        elseif ~isempty(findstr('display',a))
            a=regexprep(a,'display','Display') ;      
        elseif ~isempty(findstr('filtrans',a))
            a=regexprep(a,'filtrans','Filtrans');        
        elseif ~isempty(findstr('average',a))
            a=regexprep(a,'average','Average');        
        elseif ~isempty(findstr('geom',a))
            a=regexprep(a,'geom','Geom');        
        elseif ~isempty(findstr('iofun',a))
            a=regexprep(a,'iofun','IOfun');        
        elseif ~isempty(findstr('misc',a))
            a=regexprep(a,'misc','Misc');        
        elseif ~isempty(findstr('reconstruction',a))
            a=regexprep(a,'reconstruction','Reconstruction');        
        elseif ~isempty(findstr('sptrans',a))
            a=regexprep(a,'sptrans','Sptrans');
        elseif ~isempty(findstr('utilities',a))
            a=regexprep(a,'utilities','Utilities');
        end                
        if (~isempty(findstr('\',a)));%for windows
            b=findstr('\',a);
            c=size(b,2);
            d=a(b(c-1)+1:end);
            if ~isempty(findstr('.m',d))
                d=deblank(fliplr(d));
                d=deblank(fliplr(d(3:end)));
            end
            if i==size(lihyp,1)
                hyplpath=[hyplpath;cellstr(['<code><a style="text-decoration: none" href="..\' d '.html">' lihyp{i} '</a></code>'])];
            else
                hyplpath=[hyplpath;cellstr(['<code><a style="text-decoration: none" href="..\' d '.html">' lihyp{i} ', </a></code>'])];
            end
        elseif (~isempty(findstr('/',a)))%for linux
            b=findstr('/',a);
            c=size(b,2);
            d=a(b(c-1)+1:end);
            if i==size(lihyp,1)
                hyplpath=[hyplpath;cellstr(['<code><a style="text-decoration: none" href="../' d '.html">' lihyp{i} '</a></code>'])];
            else
                hyplpath=[hyplpath;cellstr(['<code><a style="text-decoration: none" href="../' d '.html">' lihyp{i} ', </a></code>'])];
            end        
        else
            hyplpath=[hyplpath cellstr(lihyp{i})];
        end
    end
    seealso='';
    for i=1:size(lihyp,1) 
        seealso=[seealso hyplpath{i}];
    end
else
    %nothing, cause no see also
end
%--------------------------------------------------------------------------
%- Write an HTML file for each M-file
%--------------------------------------------------------------------------
%- List of Matlab keywords (output from iskeyword)
matlabKeywords = {'break', 'case', 'catch', 'continue', 'elseif', 'else', ...
				  'end', 'for', 'function', 'global', 'if', 'otherwise', ...
				  'persistent', 'return', 'switch', 'try', 'while'};
                  %'keyboard', 'pause', 'eps', 'NaN', 'Inf'

tpl_mfile = 'mfile.tpl';

tpl_mfile_code     = '<a href="%s" class="code" title="%s">%s</a>';
tpl_mfile_keyword  = '<span class="keyword">%s</span>';
tpl_mfile_comment  = '<span class="comment">%s</span>';
tpl_mfile_string   = '<span class="string">%s</span>';
tpl_mfile_aname    = '<a name="%s" href="#_subfunctions" class="code">%s</a>';
tpl_mfile_line     = '%04d %s\n';

%- Delimiters used in strtok: some of them may be useless (% " .), removed '.'
strtok_delim = sprintf(' \t\n\r(){}[]<>+-*~!|\\@&/,:;="''%%');

%- Create the HTML template
tpl = template(options.template,'remove');
tpl = set(tpl,'file','TPL_MFILE',tpl_mfile);
tpl = set(tpl,'block','TPL_MFILE','pathline','pl');
%tpl = set(tpl,'block','TPL_MFILE','mexfile','mex'); modif will
tpl = set(tpl,'block','TPL_MFILE','script','scriptfile');
tpl = set(tpl,'block','TPL_MFILE','crossrefcall','crossrefcalls');
tpl = set(tpl,'block','TPL_MFILE','crossrefcalled','crossrefcalleds');
tpl = set(tpl,'block','TPL_MFILE','subfunction','subf');
tpl = set(tpl,'block','TPL_MFILE','source','thesource');
tpl = set(tpl,'block','TPL_MFILE','download','downloads');
tpl = set(tpl,'var','DATE',[datestr(now,8) ' ' datestr(now,1) ' ' ...
							datestr(now,13)]);

nblinetot = 0;
for i=1:length(mdir)
	for j=1:length(mdirs)
		if strcmp(mdirs{j},mdir{i})
		
			curfile = fullfile(options.htmlDir,mdir{i},...
							   [names{j} options.extension]);							   			
			%- Open for writing the HTML file
			if options.verbose
				fprintf('Creating HTML file %s...\n',curfile);
            end
			fid = openfile(curfile,'w');
			%- Open for reading the M-file
			fid2 = openfile(mfiles{j},'r');
			
			%- Set some template fields
			tpl = set(tpl,'var','NAME',             names{j});
            tpl = set(tpl,'var','CATEGORIE',        options.categorie);
			tpl = set(tpl,'var','H1LINE',           entity(h1line{j}));
			if isempty(syntax{j})%if isempty(synopsis{j}) modif will
                tpl = set(tpl,'var','SYNTAX',get(tpl,'var','script'));
			else
                tpl = set(tpl,'var','SYNTAX', syntax{j});
			end                       
			tpl = set(tpl,'var','DESCRIPTION',description);				
			tpl = set(tpl,'var','EXAMPLE',example);
            tpl = set(tpl,'var','SEE_ALSO',seealso);
            tpl = set(tpl,'var','PREV_HTML',prev_html);
            tpl = set(tpl,'var','NEXT_HTML',next_html);
            tpl = set(tpl,'var','PREV_NAME',prev_name);
            tpl = set(tpl,'var','NEXT_NAME',next_name);
			tpl = parse(tpl,'OUT','TPL_MFILE');
			fprintf(fid,'%s',get(tpl,'OUT'));
			fclose(fid2);
			fclose(fid);
		end
	end
end

%--------------------------------------------------------------------------
%- Display Statistics
%--------------------------------------------------------------------------
if options.verbose
    prnbline = '';
    if options.source
        prnbline = sprintf('(%d lines) ', nblinetot);
    end
    fprintf('Stats: %d M-files %sin %d directories documented in %d s.\n', ...
            length(mfiles), prnbline, length(mdir), round(etime(clock,t0)));
    end
%==========================================================================
function s = mfileparse(mfile, mdirs, names, options)
%Search for syntax, description, example and see also

options = struct('verbose',1, 'globalHypertextLinks',0, 'todo',0);
%- Delimiters used in strtok: some of them may be useless (% " .), removed '.'
strtok_delim = sprintf(' \t\n\r(){}[]<>+-*~!|\\@&/,:;="''%%');
%- Open for reading the M-file
fid = openfile(mfile,'r');
it = 0; % line number
%- Initialize Output
s = struct('function',   '', ...
		   'h1line',     '', ...
           'syntax',    '', ...
           'description','', ...
           'example',    '', ...
           'seealso',    '');
           
qwe='';
%--- look for the function name 
tline = fgetl(fid);
it = it + 1;
tline = entity(fliplr(deblank(fliplr(deblank(tline)))));%deblank beginning & end of the string
if ~isempty(strmatch('function',tline))
    while 1
        if isempty(strmatch('...',fliplr(deblank(tline))))
            s.function=[qwe sprintf('\n%s',tline)];
            break;
        end
        qwe=[qwe sprintf('\n%s',tline)];
        tline = fgetl(fid);
        it = it + 1 ;
        tline = entity(fliplr(deblank(fliplr(tline))));
    end
else
    message=['Check the file ' mfile '!! Keyword ''function'' not found as first line.'];
    error(message);    
end
%--- look for the H1 Line.
qwe='';
while 1
    tline = fgetl(fid);
    it = it + 1;
    tline = entity(tline);
    if ~isempty(findstr('SYNTAX',tline))
        s.h1line=qwe;              
        break;
    elseif isempty(strmatch('%',tline))%isempty(findstr('%',tline(1:1)))
        message=['Check the file ' mfile '!! Keyword ''SYNTAX'' not found.' ,...
                '\nThe file should contain the keyword ''SYNTAX''. The help file should contain: \n',...
                'SYNTAX \n',...
                '\n',...
                'DESCRIPTION \n',...
                '\n',...
                'EXAMPLE \n',...
                '\n',...
                'SEE ALSO \n'];            
        error('ErrorTests:convertTest',...
            message);            
    end                        
    qwe=[qwe sprintf('\n%s',fliplr(deblank(fliplr(deblank(tline(2:end))))))];
end   
%--- look for the syntax.
qwe='';
while 1
    tline = fgetl(fid);
    it = it + 1;
    tline = entity(tline);
    if ~isempty(findstr('DESCRIPTION',tline))
        s.syntax=qwe;              
        break;
    elseif isempty(strmatch('%',tline))%isempty(findstr('%',tline(1:1)))
        message=['Check the file ' mfile '!! Keyword ''DESCRIPTION'' not found.',...
                '\nThe file should contain the keyword ''DESCRIPTION''.The help file should contain: \n',...
                'SYNTAX \n',...
                '\n',...
                'DESCRIPTION \n',...
                '\n',...
                'EXAMPLE \n',...
                '\n',...
                'SEE ALSO \n'];            
        error('ErrorTests:convertTest',...
            message);            
    end  
    vbn=[fliplr(deblank(fliplr(deblank(tline(2:end))))) '<br>'];
    qwe=[qwe sprintf('\n%s',vbn)];
end
%--- look for the description.
qwe='';flag_ex=0;
while flag_ex==0
    tline = fgetl(fid);
    it = it + 1;
    tline = entity(tline);
    if ~isempty(findstr('EXAMPLE',tline))       
        s.description=qwe;           
        break;
    elseif ~isempty(findstr('Parameters',tline))
        %vbn=['<br>' ,...                
        vbn=[fliplr(deblank(fliplr(deblank(tline(2:end))))),... '
             '<table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse; border-width: 0" bordercolor="#111111" width="100%">',...
             ];
        qwe=[qwe sprintf('\n%s',vbn)];
        while 1
            tline = fgetl(fid);
            it = it + 1;
            %tline = entity(fliplr(deblank(fliplr(tline(2:end)))))
            tline = entity(tline(2:end));
            if ~isempty(findstr('EXAMPLE',tline))
                qwe=[qwe '</table>'];
                flag_ex=1;
                s.description=qwe;
                break;
            elseif isempty(tline)
                %no action
            elseif strmatch('Input',fliplr(deblank(fliplr(tline))))%~isempty(findstr('Input',tline(1:5)))
                vbn=['<tr>' sprintf('\n%s',''),...
                     '<td width="4%" style="border-style: none; border-width: medium">' fliplr(deblank(fliplr(tline))),...
                     '</td>' sprintf('\n%s',''),...
                     '<td width="6%" style="border-style: none; border-width: medium">&nbsp;</td>' sprintf('\n%s',''),...
                     '<td width="90%" style="border-style: none; border-width: medium">&nbsp;</td>' sprintf('\n%s',''),...
                     '</tr>' sprintf('\n%s','')];
            elseif strmatch('Output',fliplr(deblank(fliplr(tline))))%~isempty(findstr('Output',tline))
                vbn=['<tr>' sprintf('\n%s',''),...
                     '<td width="4%" style="border-style: none; border-width: medium">' fliplr(deblank(fliplr(tline))),...
                     '</td>' sprintf('\n%s',''),...
                     '<td width="6%" style="border-style: none; border-width: medium">&nbsp;</td>' sprintf('\n%s',''),...
                     '<td width="90%" style="border-style: none; border-width: medium">&nbsp;</td>' sprintf('\n%s',''),...
                     '</tr>' sprintf('\n%s','')];             
            elseif ~isempty(findstr(':',tline))                
                ss=findstr(':',tline);  
                if ss(1)>18
                    vbn=['<tr>',...
                         '<td width="4%" style="border-style: none; border-width: medium">&nbsp;</td>' sprintf('\n%s',''),...
                         '<td width="6%" style="border-style: none; border-width: medium">&nbsp;</td>' sprintf('\n%s',''),...
                         '<td width="90%" style="border-style: none; border-width: medium">' fliplr(deblank(fliplr(tline))),...
                         '</td>' sprintf('\n%s',''),...
                         '</tr>' sprintf('\n%s','')];
                else    
                    col2=fliplr(deblank(fliplr(deblank(tline(1:ss(1)-1)))));
                    col3=fliplr(deblank(fliplr(deblank(tline(ss(1):end)))));                
                    vbn=['<tr>' sprintf('\n%s',''),...
                         '<td width="4%" style="border-style: none; border-width: medium">&nbsp;</td>' sprintf('\n%s',''),... 
                         '<td width="6%" style="border-style: none; border-width: medium">' col2,...
                         '</td>' sprintf('\n%s',''),...
                         '<td width="90%" style="border-style: none; border-width: medium">' col3,...
                         '</td>' sprintf('\n%s',''),...
                         '</tr>' sprintf('\n%s','')];
                end
            elseif ~isempty(tline)
                vbn=['<tr>',...
                     '<td width="4%" style="border-style: none; border-width: medium">&nbsp;</td>' sprintf('\n%s',''),...
                     '<td width="6%" style="border-style: none; border-width: medium">&nbsp;</td>' sprintf('\n%s',''),...
                     '<td width="90%" style="border-style: none; border-width: medium">' fliplr(deblank(fliplr(tline))),...
                     '</td>' sprintf('\n%s',''),...
                     '</tr>' sprintf('\n%s','')];
            end
            qwe=[qwe sprintf('\n%s',vbn)];
            vbn='';            
        end
    elseif isempty(strmatch('%',tline))%isempty(findstr('%',tline(1:1)))
        message=['Check the file ' mfile '!! Keyword ''EXAMPLE'' not found.',...
                '\nThe file should contain the keyword ''EXAMPLE''. The help file should contain: \n',...
                'SYNTAX \n',...
                '\n',...
                'DESCRIPTION \n',...
                '\n',...
                'EXAMPLE \n',...
                '\n',...
                'SEE ALSO \n'];            
        error('ErrorTests:convertTest',...
            message);            
    end 
    qwe=[qwe sprintf('\n%s',fliplr(deblank(fliplr(deblank(tline(2:end))))))];
end
%--- look for the example.
qwe='';ficar='';
while 1
    tline = fgetl(fid);
    it = it + 1;
    tline=entity(tline);
    if ~isempty(findstr('SEE ALSO',tline))
        s.example=qwe;
        break;
    elseif isempty(strmatch('%',tline))%isempty(findstr('%',tline(1:1)))
        message=['Check the file ' mfile '!! Keyword ''SEE ALSO'' not found.',...
                '\nThe file should contain the keyword ''SEE ALSO''. The help file should contain: \n',...
                'SYNTAX \n',...
                '\n',...
                'DESCRIPTION \n',...
                '\n',...
                'EXAMPLE \n',...
                '\n',...
                'SEE ALSO \n'];            
        error('ErrorTests:convertTest',...
            message);                                             
    end  
    nbsp=isspace(tline(2:end)); 
    for i=1:size(nbsp,2)
        if nbsp(i)==0;
            tline=[ficar fliplr(deblank(fliplr(deblank(tline(2:end)))))];
            ficar='';
            break;
        else
            ficar=[ficar '&nbsp;'];
        end
    end
    if isempty(tline(2:end))
        qwe=[qwe sprintf('\n%s',tline(2:end)) '<br>'];
    else
        qwe=[qwe sprintf('\n%s',tline) '<br>'];
    end
end
%--- look for see also.
qwe='';
while 1
    tline = fgetl(fid);
    it = it + 1;
    %tline = entity(fliplr(deblank(fliplr(deblank(tline(2:end))))))
    tline = entity(tline);
    if ~isempty(findstr('Copyright',tline))
        s.seealso=qwe;
        break;
    elseif isempty(tline)
        s.seealso=qwe;
        break;        
    elseif isempty(findstr('%',tline(1:1)))
        s.seealso=qwe;
        break;
    end                        
    qwe=[qwe sprintf('\n%s',deblank(tline(2:end)))];
end
fclose(fid);

%==========================================================================
function mfiles = getmfiles(mdirs, mfiles, recursive)
	%- Extract M-files from a list of directories and/or M-files

	for i=1:length(mdirs)
		currentdir = fullfile(pwd, mdirs{i});
		if exist(currentdir) == 2 % M-file
			mfiles{end+1} = mdirs{i};
		elseif exist(currentdir) == 7 % Directory
			d = dir(fullfile(currentdir, '*.m'));
			d = {d(~[d.isdir]).name};
			for j=1:length(d)
				mfiles{end+1} = fullfile(mdirs{i}, d{j});
			end
			if recursive
				d = dir(currentdir);
				d = {d([d.isdir]).name};
				d = {d{~ismember(d,{'.' '..'})}};
				for j=1:length(d)
					mfiles = getmfiles(cellstr(fullfile(mdirs{i},d{j})), ...
									   mfiles, recursive);
				end
			end
		else
			fprintf('Warning: Unprocessed file %s.\n',mdirs{i});
			if ~isempty(strmatch('/',mdirs{i})) | findstr(':',mdirs{i})
				fprintf('         Use relative paths in ''mfiles'' option\n');
			end 
		end
	end

    
%==========================================================================
function ldir = splitpath(p)
	%- Split a filesystem path into parts using filesep as separator

	ldir = {};
	p = deblank(p);
	while 1
		[t,p] = strtok(p,filesep);
		if isempty(t), break; end
		if ~strcmp(t,'.')
			ldir{end+1} = t;
		end
	end
	if isempty(ldir)
		ldir{1} = '.'; % should be removed
	end

%==========================================================================
function str = escapeblank(str)
	%- Escape white spaces using '\'
	str = deblank(fliplr(deblank(fliplr(str))));
	str = strrep(str,' ','\ ');

%==========================================================================
function str = entity(str)
	%- See http://www.w3.org/TR/html4/charset.html#h-5.3.2
	
	str = strrep(str,'&','&amp;');
	str = strrep(str,'<','&lt;');
	str = strrep(str,'>','&gt;');
	str = strrep(str,'"','&quot;');

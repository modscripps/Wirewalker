function SN_printfig(filename,varargin)
%SN_PRINTFIG saves a specified figure as an image
%
%  SN_PRINTFIG(FILENAME) saves a specified figure as an JPG image with a
%   specified FILENAME 
%  SN_PRINTFIG(FILENAME,'OPTIONS',OPT_VAL) allows users to add more advance
%  options
%  The OPTIONS are:
%       'QUALITY':  File quality of a jpeg image ranging 0-100 (integer only)
%
%       'RESOLUTION' or 'DPI': print resolution in the unit of Dots Per Inch
%           (no negative integer only)
%
%       'PRINTSCREEN':  TRUE or FALSE, if TRUE (by default), the figure will
%           be saved as displayed on the screen, which is very useful for 
%           those who are used to doing that
%
%       'FIGURE':   specific figure handle to save instead of the current
%           figure handle
%
%       'PAPERSIZE' specify WIDTH and HEIGHT as a vector in unit of inches
%
%       'PAPERUNITS' specify either 'INCHES', 'CENTIMETERS', 'POINTS', or
%           'NORMALIZED'
%
%       'PAPERTYPE' specify either
%           'usletter'      8.5-by-11 inches
%           'uslegal'       8.5-by-14 inches
%           'tabloid'       11-by-17 inches
%           'A0'            841-by-1189 mm
%           'A1'            594-by-841 mm
%           'A2'            420-by-594 mm
%           'A3'            297-by-420 mm
%           'A4'            210-by-297 mm
%           'A5'            148-by-210 mm
%           'B0'            1029-by-1456 mm
%           'B1'            728-by-1028 mm
%           'B2'            514-by-728 mm
%           'B3'            364-by-514 mm
%           'B4'            257-by-364 mm
%           'B5'            182-by-257 mm
%           'arch-A'        9-by-12 inches
%           'arch-B'        12-by-18 inches
%           'arch-C'        18-by-24 inches
%           'arch-D'        24-by-36 inches
%           'arch-E'        36-by-48 inches
%           'A'             8.5-by-11 inches
%           'B'             11-by-17 inches
%           'C'             17-by-22 inches
%           'D'             22-by-34 inches
%           'E'             34-by-43 inches
%
%       'PAPERORIENTATION'  specifies the orientation of the specified
%           paper
%           'PORTRAIT' ? Orients the longest page dimension vertically.
%           'LANDSCAPE' ? Orients the longest page dimension horizontally
%
%       'PAPERPOSITION' specifies  the position on the paper by using a vector form
%           [LEFT, BOTTOM, WIDTH, HEIGHT] with units defined by PAPERUNITS
%
%       'FILETYPE': A string that can specify the file type you would like to
%           save. Below are the file types supported 
%       
%       eps, epsc       Encapsulated PostScript - Color (vector)
%       epsmono         Encapsulated PostScript - Black & White (vector)
%       eps2, epsc2     Encapsulated PostScript Level 2 - Color (vector)
%       epsmono2        Encapsulated PostScript Level 2 - Black & White (vector)
%       pdf             Portable Document Format File (vector)
%       jpg, jpeg       JPEG (bitmap)
%       png             PNG (bitmap)
%       ppm             Portable Pixmap Image File (bitmap)
%       ppmraw          Portable Pixmap Image File - Raw (bitmap)
%       emf, meta       Enhanced Windows Metafile (vector) 
%       bmp             Bitmap Image File (bitmap)
%       bmp16m          Bitmap Image File - 24-bit (16m colors) (bitmap)
%       bmp256          Bitmap Image File - 8-bit (256 colors) (bitmap)
%       bmpmono         Bitmap Image File - monochrome (bitmap)
%       hdf             Hierarchical Data Format File (bitmap)
%       tiff            Tagged Image File Format - compressed (bitmap)
%       tiffn           Tagged Image File Format - not compressed (bitmap)
%       pgm             Portable Gray Map Image (bitmap)
%       pgmraw          Portable Gray Map Image - Raw (bitmap)
%       svg             Scalable Vector Graphics File (vector) 
%       pcx, pcx24b     Paintbrush Bitmap Image File - 24-bit colors (bitmap)
%       pcx16           Paintbrush Bitmap Image File - 16 colors (bitmap)
%       pcx256          Paintbrush Bitmap Image File - 8-bit colors (bitmap)
%       pcxmono         Paintbrush Bitmap Image File - monochrome (bitmap)
%       pbm             Portable Bitmap Image (bitmap)
%       pbmraw          Portable Bitmap Image - Raw (bitmap)
%       ill, ai         Adobe Illustrator Image (vector)
%       ps, psc         Poscript File - Color (vector)
%       psmono          Poscript File - Black & White (vector)
%       ps2, psc2       Poscript File Level 2 - Color (vector)
%       psmono2         Poscript File Level 2 - Black & White (vector)
%
%
% Here are other options you can use without a value of each option
%   -noui      % Do not print UI control objects
%   -painters  % Rendering for printing to be done in Painters mode
%   -zbuffer   % Rendering for printing to be done in Z-buffer mode%
%   -opengl    % Rendering for printing to be done in OpenGL mode
%
% See also PRINT, SAVEAS, IMWRITE
%
% Created by San Nguyen 2012 05 09
%

persistent argsNameToCheck;
if isempty(argsNameToCheck);
    argsNameToCheck = {'FileType','Quality','DPI','Resolution','PrintScreen','Figure','Percent',...
        'PaperSize','PaperUnits','PaperType','PaperOrientation','PaperPosition'};
end

persistent fileExtensions;
if isempty(fileExtensions)
    fileExtensions = {'eps','pdf','jpg','png','ppm','emf','bmp','hdf',...
        'tiff','pgm','svg','pcx','pbm','ai', 'ps'};
                       %1    2      3     4     5     6     7     8     9     10    11    12    13    1
end

persistent fileTypes;
if isempty(fileTypes)
    fileTypes = {...
        'eps',      '-depsc',        1;... % Encapsulated PostScript - Color (vector)
        'epsc',     '-depsc',        1;... % Encapsulated PostScript - Color (vector)
        'epsmono',  '-deps',         1;... % Encapsulated PostScript - Black & White (vector)
        'eps2',     '-depsc2',       1;... % Encapsulated PostScript Level 2 - Color (vector)
        'epsc2',    '-depsc2',       1;... % Encapsulated PostScript Level 2 - Color (vector)
        'epsmono2', '-deps2',        1;... % Encapsulated PostScript Level 2 - Black & White (vector)
        'pdf',      '-dpdf',         2;... % Portable Document Format File (vector)
        'jpg',      '-djpeg',        3;... % JPEG (bitmap
        'jpeg',     '-djpeg',        3;... % JPEG (bitmap)
        'png',      '-dpng',         4;... % PNG (bitmap)
        'ppm',      '-dppm',         5;... % Portable Pixmap Image File (bitmap)
        'ppmraw',   '-ppmraw',       5;... % Portable Pixmap Image File - Raw (bitmap)
        'emf',      '-dmeta',        6;... % Enhanced Windows Metafile (vector) 
        'meta',     '-dmeta',        6;... % Enhanced Windows Metafile (vector) 
        'bmp',      '-dbmp',         7;... % Bitmap Image File (bitmap)
        'bmp16m',   '-dbmp16m',      7;... % Bitmap Image File - 24-bit (16m colors) (bitmap)
        'bmp256',   '-dbmp256',      7;... % Bitmap Image File - 8-bit (256 colors) (bitmap)
        'bmpmono',  '-dbmpmono',     7;... % Bitmap Image File - monochrome (bitmap)
        'hdf',      '-dhdf',         8;... % Hierarchical Data Format File (bitmap)
        'tiff',     '-dtiff',        9;... % Tagged Image File Format - compressed (bitmap)
        'tiffn',    '-dtiffn',       9;... % Tagged Image File Format - not compressed (bitmap)
        'pgm',      '-dpgm',        10;... % Portable Gray Map Image (bitmap)
        'pgmraw',   '-dpgmraw',     10;... % Portable Gray Map Image - Raw (bitmap)
        'svg',      '-dsvg',        11;... % Scalable Vector Graphics File (vector) 
        'pcx',      '-dpcx24b',     12;... % Paintbrush Bitmap Image File - 24-bit colors (bitmap)
        'pcx16',    '-dpcx16',      12;... % Paintbrush Bitmap Image File - 16 colors (bitmap)
        'pcx24b',   '-dpcx24b',     12;... % Paintbrush Bitmap Image File - 24-bit colors (bitmap)
        'pcx256',   '-dpcx256',     12;... % Paintbrush Bitmap Image File - 8-bit colors (bitmap)
        'pcxmono',  '-dpcxmono',    12;... % Paintbrush Bitmap Image File - monochrome (bitmap)
        'pbm',      '-dpbm',        13;... % Portable Bitmap Image (bitmap)
        'pbmraw',   '-dpbmraw',     13;... % Portable Bitmap Image - Raw (bitmap)
        'ill',      '-dill',        14;... % Adobe Illustrator Image (vector)
        'ai',       '-dill',        14;... % Adobe Illustrator Image (vector)
        'ps',       '-dpsc',        15;... % Poscript File - Color (vector)
        'psc',      '-dpsc',        15;... % Poscript File - Color (vector)
        'psmono',   '-dps',         15;... % Poscript File - Black & White (vector)
        'ps2',      '-dpsc2',       15;... % Poscript File Level 2 - Color (vector)
        'psc2',     '-dpsc2',       15;... % Poscript File Level 2 - Color (vector)
        'psmono2',  '-dps2',        15;};   % Poscript File Level 2 - Black & White (vector)
end

persistent paperTypes;
if isempty(paperTypes)
    paperTypes = {...
        'usletter';... %      8.5-by-11 inches
        'uslegal';... %       8.5-by-14 inches
        'tabloid';... %       11-by-17 inches
        'A0';... %                  841-by-1189 mm
        'A1';... %                  594-by-841 mm
        'A2';... %                  420-by-594 mm
        'A3';... %                  297-by-420 mm
        'A4';... %                  210-by-297 mm
        'A5';... %                  148-by-210 mm
        'B0';... %                  1029-by-1456 mm
        'B1';... %                  728-by-1028 mm
        'B2';... %                  514-by-728 mm
        'B3';... %                  364-by-514 mm
        'B4';... %                  257-by-364 mm
        'B5';... %                  182-by-257 mm
        'arch-A';... %              9-by-12 inches
        'arch-B';... %              12-by-18 inches
        'arch-C';... %              18-by-24 inches
        'arch-D';... %              24-by-36 inches
        'arch-E';... %              36-by-48 inches
        'A';... %                   8.5-by-11 inches
        'B';... %                   11-by-17 inches
        'C';... %                   17-by-22 inches
        'D';... %                   22-by-34 inches
        'E';... %                   34-by-43 inches
        };
end

persistent paperUnits;
if isempty(paperUnits)
    paperUnits = {'inches','centimeters','points','normalized'};
end

persistent paperOrientations;
if isempty(paperOrientations)
    paperOrientations = {'portrait','landscape'};
end

if isempty(filename) || ~ischar(filename)
    error('MATLAB:SN_printfig:emptyFilename','You are missing a filename...');
end
FileType = '';
FileTypeN = [];
FileTypePrintCmd = '';
Quality = 90;
DPI = 72;
PrintScreen = true;
Figure = gcf;
Percent = 100;
PaperSize = [];
PaperUnits = '';
PaperType = '';
PaperOrientation = '';
PaperPosition = [];
isOtherPrintOptions = false(size(varargin));

index = 1;
n_items = nargin-1;
while (n_items > 0)
    argsMatch = strcmpi(varargin{index},argsNameToCheck);
    i = find(argsMatch,1);
    if isempty(i)
        isOtherPrintOptions(index) = true;
        index = index +1;
        n_items = n_items-1;
        continue;
    end
    
    switch i
        case 1 % filetype
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            FileType = varargin{index+1};
            if isempty(FileType) || ~ischar(FileType)
                error('MATLAB:SN_printfig:emptyFileType','Please check your filetype');
            end            
            FileTypeN = find(strcmpi(FileType,fileTypes(:,1)),1);
            if isempty(FileTypeN)
                error('MATLAB:SN_printfig:wrongFileType','Please check your filetype');
            end
            index = index +2;
            n_items = n_items-2;
        case 2 % quality
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            Quality = ceil(varargin{index+1});

            if (Quality < 1)
                error('MATLAB:SN_printfig:QualInteger',...
                    'Quality value must be an integer greater than zero');
            end
            
            index = index +2;
            n_items = n_items-2;
        case 3 % dpi
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            DPI = ceil(varargin{index+1});
            if DPI < 1
                error('MATLAB:SN_printfig:DPIInteger',...
                    'Resolution value (DPI) value must be an integer greater than zero');
            end
            
            index = index +2;
            n_items = n_items-2;
            
        case 4 % resolution
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            DPI = ceil(varargin{index+1});
            if DPI < 1
                error('MATLAB:SN_printfig:DPIInteger',...
                    'Resolution value (DPI) value must be an integer greater than zero');
            end
            
            index = index +2;
            n_items = n_items-2;
            
        case 5 % printscreen
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            PrintScreen = varargin{index+1};
            if ~islogical(PrintScreen)
                error('MATLAB:SN_printfig:PrintScreent',...
                    'PrintScreen must be logical');
            end
            
            index = index +2;
            n_items = n_items-2;
            
        case 6 % figure
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            Figure = varargin{index+1};
            
            % check for a valid figure;
            iptcheckhandle(Figure,{'figure'},'SN_printfig','Figure',index+1)
            
            index = index +2;
            n_items = n_items-2;
            
        case 7 % percent
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            Percent = varargin{index+1};
            if Percent < 0
                error('MATLAB:SN_printfig:Percent0','Percentage must be greater than zero');
            end
            
            index = index +2;
            n_items = n_items-2;
        case 8 % paper size
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            PaperSize = varargin{index+1};
            if ~isnumeric(PaperSize) && length(PaperSize) ~= 2
                error('MATLAB:SN_printfig:PaperSize','PAPERSIZE must be a vector of two elements');
            end
            index = index +2;
            n_items = n_items-2;
            
        case 9 % paper units
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            PaperUnits = varargin{index+1};
            if isempty(find(strcmpi(PaperUnits,paperUnits),1))
                error('MATLAB:SN_printfig:PaperUnits','PAPERUNITS is not specified correctly');
            end
            index = index +2;
            n_items = n_items-2;
        case 10 % paper type
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            PaperType = varargin{index+1};
            if isempty(find(strcmpi(PaperType,paperTypes),1))
                error('MATLAB:SN_printfig:PaperType','PAPERTYPE is not specified correctly');
            end
            index = index +2;
            n_items = n_items-2;
        case 11 % paper orientation
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            PaperOrientation = varargin{index+1};
            if isempty(find(strcmpi(PaperOrientation,paperOrientations),1))
                error('MATLAB:SN_printfig:PaperOrientation','PAPERORIENTATION is not specified correctly');
            end
            index = index +2;
            n_items = n_items-2;
        case 12 % paper position
            if n_items == 1
                error('MATLAB:SN_printfig:missingArgs','Missing input arguments');
            end
            PaperPosition = varargin{index+1};
            if ~isnumeric(PaperPosition) && length(PaperPosition) ~= 4
                error('MATLAB:SN_printfig:PaperPosition','PAPERPOSITION must be a vector of 4 elements');
            end
            index = index +2;
            n_items = n_items-2;
    end
end

% the next few lines will determine the right filetype to print
FileEnding = find(filename == '.',1,'last');
FileAddExt = true;
if ~isempty(FileEnding)
    FileEnding = filename(FileEnding+1:end);
end
    
% if ~isempty(FileType)
%     FileTypeN = find(strcmpi(FileType,fileTypes{:,1}),1);
% end
if ~isempty(FileTypeN)
    FileExt = fileExtensions{fileTypes{FileTypeN,3}};
    FileTypePrintCmd = fileTypes{FileTypeN,2};
    if strcmpi(FileEnding,fileTypes(FileTypeN,1))
        FileAddExt = false;
    end    
else    
    i = find(strcmpi(FileEnding,fileTypes(:,1)),1);
    if isempty(i)
        FileExt = 'jpg';
%         FileType = 'jpg';
        FileTypeN = 8;
    else
        FileExt = FileEnding;
%         FileType = FileEnding;
        FileTypeN = find(strcmpi(FileEnding,fileTypes(:,1)),1);
        FileAddExt = false;
    end
    FileTypePrintCmd = fileTypes{FileTypeN,2};
end

if FileAddExt
    filename = sprintf('%s.%s',filename,FileExt);
end

if FileTypeN == 8 % specify quality for JPG only
    FileTypePrintCmd = sprintf('%s%02d',FileTypePrintCmd,Quality);
end

DPI = ceil(DPI*Percent/100);
DPIcmd = sprintf('-r%d',DPI);

% this is where we set the proportions of the figure correctly so that the output looks 
% like what's on the screen 
oldscreenunits = get(Figure,'Units');
oldpaperunits = get(Figure,'PaperUnits');
oldpaperpos = get(Figure,'PaperPosition');
oldpapertype = get(Figure,'PaperType');
oldpaperposmode = get(Figure,'PaperPositionMode');
oldpapersize = get(Figure,'PaperSize');
oldpaperorientation = get(gcf,'PaperOrientation');
    
if PrintScreen
    set(Figure,'Units','pixels');
    scrpos = get(Figure,'Position');
    newpos = [0 0 scrpos(end-1:end)]/DPI;
    set(Figure,'PaperUnits','inches',...
        'PaperPosition',newpos,'PaperSize',newpos(end-1:end))
    print(Figure,FileTypePrintCmd,filename,DPIcmd,varargin{isOtherPrintOptions});
    drawnow;
else
    if ~isempty(PaperUnits)
        set(Figure,'PaperUnits',PaperUnits);
    end
    if ~isempty(PaperType)
        set(Figure,'PaperType',PaperType);
    end
    if ~isempty(PaperSize)
        set(Figure,'PaperSize',PaperSize);
    end
    if ~isempty(PaperOrientation)
        set(Figure,'PaperOrientation',PaperOrientation);
    end
    if ~isempty(PaperPosition)
        set(Figure,'PaperPosition',PaperPosition);
    end
    print(Figure,FileTypePrintCmd,filename,DPIcmd,varargin{isOtherPrintOptions});
    drawnow;
end

set(Figure,'Units',oldscreenunits,...
    'PaperUnits',oldpaperunits,...
    'PaperPosition',oldpaperpos,...
    'PaperPositionMode',oldpaperposmode,...
    'PaperSize',oldpapersize,...
    'PaperType',oldpapertype,...
    'PaperOrientation',oldpaperorientation);

end



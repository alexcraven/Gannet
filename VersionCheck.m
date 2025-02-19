function varargout = VersionCheck(silent, currentVersion)
% Code adopted from Yair Altman's export_fig toolbox
% (https://github.com/altmany/export_fig)

% Check if there's a connection to the internet
try
    java.net.InetAddress.getByName('www.google.com');
catch
    warning('No internet connection. Skipping version check.');
    return
end

persistent lastCheckTime

if nargin < 2
    loadFile = which('GannetLoad');
    fileID = fopen(loadFile, 'rt');
    if fileID == -1
        fclose(fileID);
        error('Cannot read %s.', loadFile);
    end
    str = fread(fileID, Inf, '*uchar');
    fclose(fileID);
    str = char(str(:)');
    expression = '(?<field>MRS_struct.version.Gannet = )''(?<version>.*?)''';
    out = regexp(str, expression, 'names');
    currentVersion = out.version;
    if nargin < 1
        silent = 0;
    end
end

newVersionAvailable = 0;
if nargin < 2 || isempty(lastCheckTime) || (datetime('now') - lastCheckTime) > days(1)
    url = 'https://raw.githubusercontent.com/markmikkelsen/Gannet/main/GannetLoad.m';
    str = readURL(url);
    expression = '(?<field>MRS_struct.version.Gannet = )''(?<version>.*?)''';
    out = regexp(str, expression, 'names');
    latestVersion = out.version;
    if str2double(latestVersion(regexpi(latestVersion,'\d'))) > str2double(currentVersion(regexpi(currentVersion,'\d')))
        newVersionAvailable = 1;
        msg = ['\n', ...
               '***********************************************************************************************\n', ...
               'A newer version of Gannet (%s) is available. You are currently using version %s.\n' ...
               'You can download the newer version from GitHub or run UpdateGannet to install it directly.\n', ...
               '***********************************************************************************************\n\n'];
        msg = hyperlink('https://github.com/markmikkelsen/Gannet', 'GitHub', msg);
        msg = hyperlink('matlab:UpdateGannet', 'UpdateGannet', msg);
        if ~silent
            fprintf(msg, latestVersion, currentVersion);
        end
    end
    lastCheckTime = datetime('now');
end

if nargout == 1
    varargout{1} = currentVersion;
elseif nargout == 2
    varargout{1} = currentVersion;
    varargout{2} = newVersionAvailable;
end

    function str = readURL(url)
        try
            str = char(webread(url));
        catch err
            if isempty(strfind(err.message,'404'))
                v = version;
                if v(1) >= '8' % 8.0 (R2012b)
                    str = urlread(url, 'Timeout', 5); %#ok<URLRD>
                else
                    str = urlread(url); %#ok<URLRD> % R2012a or older (no timeout parameter)
                end
            else
                rethrow(err);
            end
        end
        if size(str,1) > 1  % ensure a row-wise string
            str = str';
        end
    end

end




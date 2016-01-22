function [success,theMessage] = xlswrite(varargin)

% XLSWRITE Write to Microsoft Excel spreadsheet file.
%   XLSWRITE(FILE,ARRAY) writes ARRAY to the first worksheet in the Excel
%   file named FILE, starting at cell A1.
%
%   XLSWRITE(FILE,ARRAY,SHEET) writes to the specified worksheet.
%
%   XLSWRITE(FILE,ARRAY,RANGE) writes to the rectangular region
%   specified by RANGE in the first worksheet of the file. Specify RANGE
%   using the syntax 'C1:C2', where C1 and C2 are opposing corners of the
%   region.
%
%   XLSWRITE(FILE,ARRAY,SHEET,RANGE) writes to the specified SHEET and
%   RANGE.
%
%   STATUS = XLSWRITE(FILE,ARRAY,SHEET,RANGE) returns the completion
%   status of the write operation: TRUE (logical 1) for success, FALSE
%   (logical 0) for failure.  Inputs SHEET and RANGE are optional.
%
%   [STATUS,MESSAGE] = XLSWRITE(FILE,ARRAY,SHEET,RANGE) returns any warning
%   or error messages generated by the write operation in structure
%   MESSAGE. The structure contains two fields: 'message' and 'identifier'.
%   Inputs SHEET and RANGE are optional.
%
%   Input Arguments:
%
%   FILE    String that specifies the file to write. If the file does not
%           exist, XLSWRITE creates a file, determining the format based on
%           the specified extension. To create a file compatible with Excel
%           97-2003 software, specify an extension of '.xls'. To create
%           files in Excel 2007 or later formats, specify an extension of
%           '.xlsx', '.xlsb', or '.xlsm'. If you do not specify an 
%           extension, XLSWRITE applies '.xls'.
%   ARRAY   Two-dimensional numeric or character array or, if each cell
%           contains a single element, a cell array.
%   SHEET   Worksheet to write. One of the following:
%           * String that contains the worksheet name.
%           * Positive, integer-valued scalar indicating the worksheet
%             index.
%           If SHEET does not exist, XLSWRITE adds a new sheet at the end
%           of the worksheet collection. If SHEET is an index larger than
%           the number of worksheets, XLSWRITE appends new sheets until the
%           number of worksheets in the workbook equals SHEET.
%   RANGE   String that specifies a rectangular portion of the worksheet to
%           read. Not case sensitive. Use Excel A1 reference style.
%           * If you specify a SHEET, RANGE can either fit the size of
%             ARRAY or specify only the first cell (such as 'D2').
%           * If you do not specify a SHEET, RANGE must include both 
%             corners and a colon character (:), even for a single cell
%             (such as 'D2:D2').
%           * If RANGE is larger than the size of ARRAY, Excel fills the
%             remainder of the region with #N/A. If RANGE is smaller than
%             the size of ARRAY, XLSWRITE writes only the subset that fits
%             into RANGE to the file.
%
%   Notes:
%
%   * If your system does not have Excel for Windows, or if the COM server
%     (part of the typical installation of Excel) is unavailable, XLSWRITE:
%        * Writes ARRAY to a text file in comma-separated value (CSV) format.
%        * Ignores SHEET and RANGE arguments.
%        * Generates an error when ARRAY is a cell array.
%
%   * Excel converts Inf values to 65535. XLSWRITE converts NaN values to
%     empty cells.
%
%   Examples:
%
%   % Write a 7-element vector to testdata.xls:
%   xlswrite('testdata.xls', [12.7, 5.02, -98, 63.9, 0, -.2, 56])
%
%   % Write mixed text and numeric data to testdata2.xls
%   % starting at cell E1 of Sheet1:
%   d = {'Time','Temperature'; 12,98; 13,99; 14,97};
%   xlswrite('testdata2.xls', d, 1, 'E1')

%   Copyright 1984-2015 The MathWorks, Inc.
%==============================================================================
% Set default values.

% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2016 DataONE
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

    import org.dataone.client.run.RunManager;
    
    runManager = RunManager.getInstance();   
    
    if ( runManager.configuration.debug)
        disp('Called the xlswrite wrapper function.');
    end
    
    % Remove wrapper xlswrite from the Matlab path
    overloadedFunctPath = which('xlswrite');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded xlswrite function.');  
    end
     
    % Call xlswrite
    source = varargin{1};
    [success,theMessage] = xlswrite( varargin{:} );
   
    % Add the wrapper xlswrite back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded xlswrite function back.');
    end
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_writes )
        formatId = 'application/vnd.ms-excel';
        import org.dataone.client.v2.DataObject;
        
        fullSourcePath = which(source);
        if isempty(fullSourcePath)
            [status, struc] = fileattrib(source);
            fullSourcePath = struc.Name;
        end
        
        existing_id = runManager.execution.getIdByFullFilePath( ...
            fullSourcePath);
        if ( isempty(existing_id) )
            % Add this object to the execution objects map
            pid = char(java.util.UUID.randomUUID()); % generate an id
            dataObject = DataObject(pid, formatId, fullSourcePath);
            runManager.execution.execution_objects(dataObject.identifier) = ...
                dataObject;
           
        else
            % Update the existing map entry with a new DataObject
            pid = existing_id;
            dataObject = DataObject(pid, formatId, fullSourcePath);
            runManager.execution.execution_objects(dataObject.identifier) = ...
                dataObject;
       
        end
     
        if ( ~ ismember(pid, runManager.execution.execution_output_ids) )
            runManager.execution.execution_output_ids{end+1} = pid;
           
        end
    end
end
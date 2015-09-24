function ncwrite( source, varname, varargin )
% NCWRITE A provenance wrapper function to the builtin NetCDF ncwritE
%    VARDATA = NCWRITE(FILENAME, VARNAME, VARDATA) write numerical or char data in
%    VARDATA to an existing variable VARNAME in the NetCDF file FILENAME,
%    and generates provenance inforamtion about the write event
%    VARDATA is written starting at the beginning of the variable and
%    unlimited dimensions are automatically extended if needed.
 
%    If FILENAME or VARNAME do not exist, use NCCREATE first.
 
%    ncwrite(FILENAME, VARNAME, VARDATA, START)
%    ncwrite(FILENAME, VARNAME, VARDATA, START, STRIDE) writes VARDATA to
%    an existing variable VARNAME in file FILENAME beginning at the
%    location given by START. For an N-dimensional variable START is a
%    vector of 1-based indices of length N specifying the starting
%    location. The optional argument STRIDE, also of length N,  specifies
%    the inter-element spacing. STRIDE defaults to a vector of ones. Use
%    this syntax to append data to an existing variable or write partial
%    data.
 
%    If VARNAME already exists, ncwrite expects the datatype of VARDATA to
%    match the NetCDF variable datatype. If VARNAME has a fill value,
%    'scale_factor' or 'add_offset' attribute, ncwrite expects data in
%    double format and will cast VARDATA to the NetCDF data type after
%    applying the following attribute conventions in sequence:
%      1. The value of 'add_offset' attribute is subtracted from VARDATA
%      2. VARDATA is divided by the value of 'scale_factor' attribute.
%      3. NaNs in VARDATA are replaced by the value of the '_FillValue'
%         attribute. If this attribute does not exist, ncwrite will try to
%         use the fill value for this variable as reported by the library.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2015 DataONE
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


    disp('Called the ncwrite wrapper function.');

    % Remove wrapper ncwrite from the Matlab path
    overloadedFunctPath = which('ncwrite');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    disp('remove the path of the overloaded ncwrite function.');  
    
    % Call ncwrite
    ncwrite( source, varname, varargin{:} );
   
    % Add the wrapper ncwrite back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    disp('add the path of the overloaded ncwrite function back.');
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance

    import org.dataone.client.run.RunManager;
    import java.net.URI;
    
    runManager = RunManager.getInstance();   
    dataPackage = runManager.getDataPackage();    
    d1_cn_resolve_endpoint = runManager.getD1_CN_Resolve_Endpoint();

    exec_output_id_list = runManager.getExecOutputIds();
    exec_output_id_list.put(source, 'application/netcdf');
    copyfile(source, runManager.runDir); % copy local source file to the run directory
    
    %if isempty(exec_output_id_list) == 1   
    %    exec_output_id_list = {source};       
    %else
    %    exec_output_id_list = unique(union(exec_output_id_list, source));
    %end
   
    % Update the execOutputIds in the runManager
    %runManager.setExecOutputIds(exec_output_id_list);
    
    % Debug
    exec_output_id_list = runManager.getExecOutputIds();
    %size(exec_output_id_list)
    %celldisp(exec_output_id_list); 
end
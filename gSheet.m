% Retrieve up to date values from a Google Sheet
% Written By Harrison Lambert for Cal Poly Senior Space Design
% Future updates: The Google API (GAPI) is finicky with returning CSV's,
% this is the same way when using javascript so it might not even be
% something possible to fix at the time of writing this. Also working on
% constructor method so that workbook and sheet ID can be more easily set
% at declaration of class instance.

% Example Spreadsheet With Formatting Rules: 
% https://docs.google.com/spreadsheets/d/13WsSdIpNtLe1xteWeX_KNnjBzDkQdGa1HnoEpbK6GAc/edit#gid=0
classdef gSheet
    
    properties
       data; 
    end
    
   properties (Access = public, Constant = true)
      
       conn = NaN;
       workbookId = '13WsSdIpNtLe1xteWeX_KNnjBzDkQdGa1HnoEpbK6GAc';
   
   end
   
   methods
    function obj = set.data(obj,value)
     if (value > 0)
        obj.data = value;
     else
        error('Property value must be positive')
     end
    end
   end
   
   methods (Static)
       
    function [sheet,status] = load(sheetid)
        import matlab.net.*
        import matlab.net.http.*
        r = RequestMessage;
        path = strcat('https://docs.google.com/spreadsheet/ccc?key=',gSheet.workbookId);
        path = strcat(path,'&gid=');
        path = strcat(path,sheetid);
        path = strcat(path,'&output=csv');
        uri=URI(path);
        resp = r.send(uri);
        status = resp.StatusCode;
        sheet = table2array(resp.Body.Data);
    end      
    
    function cellVal = cell(data,rowName,columnName)
        rowName = string(rowName);
        columnName = string(columnName);
        row = 0;
        col = 0;
        for i=1:size(data,1)
           rCell = string(data(i,2));
           if eq(rCell,rowName)
              row = i; 
           end
        end
        for j=1:size(data,2)
            cCell=string(data(1,j));
           if eq(cCell,columnName)
              col = j;
           end
        end
        if col==0 || row==0
            cellVal = NaN;
        else
            cellVal = double(string(data(row,col)));
        end
    end
   end
end

% test_libraries_updated.m
% Author: Martin Szuc (231284)
% Updated test script for DLLs with fixed function names (32-bit version)

close all; clear all; clc

fprintf('Current directory: %s\n', pwd);

%% Step 1: Test operace.dll
fprintf('\n===== TESTING OPERACE.DLL =====\n');

try
    % Unload library if already loaded
    if libisloaded('operace')
        fprintf('Unloading previously loaded operace library...\n');
        unloadlibrary('operace');
    end
    
    fprintf('Loading operace.dll...\n');
    headerPath = fullfile(pwd, 'operace.h');
    fprintf('Header file: %s\n', headerPath);
    
    if ~exist(headerPath, 'file')
        error('Header file operace.h not found!');
    end
    
    dllPath = fullfile(pwd, 'operace.dll');
    if ~exist(dllPath, 'file')
        error('DLL file operace.dll not found!');
    end
    
    [notfound, warnings] = loadlibrary('operace.dll', headerPath, 'mfilename', 'operace_mx');
    if ~isempty(warnings)
        fprintf('Warnings during loading:\n');
        disp(warnings);
    end
    
    fprintf('Available functions in operace.dll:\n');
    libfunctions('operace', '-full')
    
    % Test soucet function
    fprintf('\nTesting soucet function:\n');
    a = 11; b = -5; c = 3;
    fprintf('soucet(%d, %d, %d) = ', a, b, c);
    try
        result = calllib('operace', 'soucet', a, b, c);
        fprintf('%d\n', result);
        if result == (a + b + c)
            fprintf('SUCCESS: Results match!\n');
        else
            fprintf('ERROR: Results do not match! Expected: %d\n', a + b + c);
        end
    catch err
        fprintf('ERROR calling soucet: %s\n', err.message);
    end
    
    % Test fpu_op function
    fprintf('\nTesting fpu_op function:\n');
    x = 10; y = pi;
    fprintf('fpu_op(%d, %f) = ', x, y);
    try
        result = calllib('operace', 'fpu_op', x, y);
        fprintf('%f\n', result);
        expected = x / y;
        if abs(result - expected) < 0.0001
            fprintf('SUCCESS: Results match!\n');
        else
            fprintf('ERROR: Results do not match! Expected: %f\n', expected);
        end
    catch err
        fprintf('ERROR calling fpu_op: %s\n', err.message);
    end
    
    fprintf('\nUnloading operace library...\n');
    unloadlibrary('operace');
    
catch err
    fprintf('ERROR with operace.dll: %s\n', err.message);
end

%% Step 2: Test tictoc.dll
fprintf('\n===== TESTING TICTOC.DLL =====\n');

try
    if libisloaded('tictoc')
        fprintf('Unloading previously loaded tictoc library...\n');
        unloadlibrary('tictoc');
    end
    
    fprintf('Loading tictoc.dll...\n');
    headerPath = fullfile(pwd, 'tictoc.h');
    fprintf('Header file: %s\n', headerPath);
    
    if ~exist(headerPath, 'file')
        error('Header file tictoc.h not found!');
    end
    
    dllPath = fullfile(pwd, 'tictoc.dll');
    if ~exist(dllPath, 'file')
        error('DLL file tictoc.dll not found!');
    end
    
    [notfound, warnings] = loadlibrary('tictoc.dll', headerPath, 'mfilename', 'tictoc_mx');
    if ~isempty(warnings)
        fprintf('Warnings during loading:\n');
        disp(warnings);
    end
    
    fprintf('Available functions in tictoc.dll:\n');
    libfunctions('tictoc', '-full')
    
    fprintf('\nTesting timing functions:\n');
    % Create a pointer for the counter (2 x int32)
    v = [0 0]; 
    pv = libpointer('int32Ptr', v);
    
    fprintf('Starting timer...\n');
    try
        calllib('tictoc', 'M_tic', pv);
        
        fprintf('Performing computation...\n');
        I = 0; MAX = 1e4;
        for i = 0:MAX
            for j = 0:MAX
                I = I + 1;
            end
        end
        
        try
            toc_time = calllib('tictoc', 'M_toc', pv) / 1000000; % Convert to seconds
            fprintf('M_toc result: %f seconds\n', toc_time);
        catch err
            fprintf('ERROR calling M_toc: %s\n', err.message);
        end
        
        try
            rtoc_time = calllib('tictoc', 'M_rtoc', pv) / 1000; % Convert to seconds
            fprintf('M_rtoc result: %f seconds\n', rtoc_time);
        catch err
            fprintf('ERROR calling M_rtoc: %s\n', err.message);
        end
        
    catch err
        fprintf('ERROR calling M_tic: %s\n', err.message);
    end
    
    fprintf('\nUnloading tictoc library...\n');
    unloadlibrary('tictoc');
    
catch err
    fprintf('ERROR with tictoc.dll: %s\n', err.message);
    fprintf('Note: If you are using 64-bit MATLAB, you must compile the DLLs for 64-bit.\n');
end

fprintf('\n===== TESTING COMPLETE =====\n');

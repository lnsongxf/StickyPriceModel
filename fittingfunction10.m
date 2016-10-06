function [ f ] = fittingfunction10( p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)

% WARNING: stoch_simul() will inherit whatever options were previously run
% PERHAPS: hard code these options_ in this function
    tic
    % get Dynare structures
    global oo_ M_ options_ pvarcoirfs_clean COUNT
    % This ensures that we don't use the dr or irfs from the last stoch_simul()
    load level0workspace oo_ options_
    
    %% Set parameters
    set_param_value('eta', p1 );
    set_param_value('gamma', p2 );
    set_param_value('phi', p3 );
    set_param_value('lambda_bar', p4 );
    set_param_value('psi_N', p5 );
    set_param_value('rhozeta', p6 );
    set_param_value('rhozeta2', p7 );
    set_param_value('sigmazeta', p8 );
    % set_param_value('zetabar', p9 );
    set_param_value('rho_lambda', p10 );
    
    COUNT.total = COUNT.total + 1;

     try
         %% 2. Solve Again
        % Here we want to run the following dynare command:
        % stoch_simul(order=1,periods=600, irf=10, nograph, nodisplay, nocorr, nofunctions, nomoments, noprint, loglinear);
        % Dynare commands do not work in m files. Here's what it is in matlab:
        
        options_.irf = 11;
        options_.loglinear = 1;
        options_.nocorr = 1;
        options_.nodisplay = 1;
        options_.nograph = 1;
        options_.nomoments = 1;
        options_.noprint = 1;          % this turns off all display
        options_.order = 1;
        options_.periods = 600;
        var_list_=[];
        info = stoch_simul(var_list_); 
        
        %% 3. Compute Distance from IRFs
        % TODO: perhaps I can refactor this code so it's faster (for instance,
        % dont load the VAR irfs every single time. and dont compute so many
        % extra objects
        post_processing_irfs;                                                       % Create IRFs with trend
        post_processing_irfs_distance;                                              % Compute distance between model and VAR IRFs
        
        if sum(oo_.steady_state == Inf) > 0
            % Dynare got a steady state with Inf values
            disp('Dynare got a steady state with Inf values. Why?')
            % params
            % keyboard
            f = 10000000000;
        else
            f = irf_distance;
            COUNT.ss_found = COUNT.ss_found + 1;
        end
     catch
         try
            options_.noprint = 0;
            var_list_=[];
            info = stoch_simul(var_list_); 
         end
         
        % keyboard
        % params
        disp('Error: No ss or no irfs found')
        COUNT.ss_notfound = COUNT.ss_notfound + 1;
        
        % Dynare threw a command. Apply large penalty
        f = 10000000000;
    end
    toc

    
end



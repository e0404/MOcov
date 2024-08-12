function write_text_output(obj, output_fn)   
    monitor=obj.monitor;
    if strcmp(output_fn,'cmdline')
        to_cmd = true;
        notify(monitor,'Writing result to command line');
    else 
        to_cmd = false;
        notify(monitor,sprintf('Writing result to text in %s', output_fn));
    end
            
    mfiles=obj.mfiles;
    n=numel(mfiles);

    out_str = '';
    
    cov_data=get_cov_data(obj);

    max_fpath_length=max(cellfun(@numel,cov_data(:,1)));
    total_lines_executable=sum(cell2mat(cov_data(:,2)));
    max_lines_executable_digits=numel(num2str(total_lines_executable,'%d'));
    total_lines_missed=sum(cell2mat(cov_data(:,3)));
    max_lines_missed_digits=numel(num2str(total_lines_missed,'%d'));
    total_coverage=1-total_lines_missed/total_lines_executable;

    header_names={'Name','Stmts','Miss','Cover'};   
    total_str='TOTAL';

    col_space_l=3;

    col_lengths = [...
        max([numel(header_names{1}) numel(total_str) max_fpath_length]), ...
        max([numel(header_names{2}) max_lines_executable_digits]) + col_space_l, ...
        max([numel(header_names{3}) max_lines_missed_digits]) +  col_space_l, ...
        max([numel(header_names{4}) numel('100%')]) + col_space_l];
    
    total_table_length=sum(col_lengths);
    separator_str=repmat('-',1,total_table_length);

    %Write header
    out_str=sprintf('%s%s\n',out_str,[...
        header_names{1}, get_table_whitespace(header_names{1},col_lengths(1)),...
        get_table_whitespace(header_names{2},col_lengths(2)),header_names{2},...
        get_table_whitespace(header_names{3},col_lengths(3)),header_names{3},...
        get_table_whitespace(header_names{4},col_lengths(4)),header_names{4}]);

    %Separator
    out_str=sprintf('%s%s\n',out_str,separator_str);
        
    %Lines
    for k=1:n
        out_str=sprintf('%s%s%s',out_str,cov_data{k,1}, get_table_whitespace(cov_data{k,1},col_lengths(1)));
        
        stmts_str=sprintf('%d',cov_data{k,2});
        out_str=sprintf('%s%s%s',out_str,get_table_whitespace(stmts_str,col_lengths(2)),stmts_str);

        miss_str=sprintf('%d',cov_data{k,3});
        out_str=sprintf('%s%s%s',out_str,get_table_whitespace(miss_str,col_lengths(3)),miss_str);

        cover_str=sprintf('%d%%',round(cov_data{k,4}*100));
        out_str=sprintf('%s%s%s',out_str,get_table_whitespace(cover_str,col_lengths(3)),cover_str);
        
        out_str=sprintf('%s\n',out_str);
    end

    %Separator
    out_str=sprintf('%s%s\n',out_str,separator_str);

    %Total
    out_str=sprintf('%s%s%s',out_str,total_str, get_table_whitespace(total_str,col_lengths(1)));
    
    stmts_str=sprintf('%d',total_lines_executable);
    out_str=sprintf('%s%s%s',out_str,get_table_whitespace(stmts_str,col_lengths(2)),stmts_str);

    miss_str=sprintf('%d',total_lines_missed);
    out_str=sprintf('%s%s%s',out_str,get_table_whitespace(miss_str,col_lengths(3)),miss_str);
        
    cover_str=sprintf('%d%%',round(total_coverage*100));
    out_str=sprintf('%s%s%s',out_str,get_table_whitespace(cover_str,col_lengths(4)),cover_str);
    
    if to_cmd
        fprintf('%s\n\n',out_str);
        msg='written to command line';
    else
        write_to_file(output_fn,out_str);
        msg=sprintf('written to %s',output_fn);
    end
    
    notify(monitor,msg);

function write_to_file(fn,s)
    fid=fopen(fn,'w');
    cleaner=onCleanup(@()fclose(fid));
    fprintf(fid,'%s',s);

function str_whitespace = get_table_whitespace(content,max_length)
    c_length = numel(content);
    padding = max_length - c_length;
    str_whitespace = repmat(' ',1,padding);
    

function cov_data = get_cov_data(obj)
    
    mfiles=obj.mfiles;
    n=numel(mfiles);

    cov_data=cell(n,4);
    
    for k=1:n
        mfile=mfiles{k};
        
        %Relative Filename
        cov_data{k,1}=mocov_get_relative_path(obj.root_dir,get_filename(mfile));
        
        %executed lines
        able=get_lines_executable(mfile);
        ed=get_lines_executed(mfile);
        
        cov_data{k,2}=sum(able); %executable
        cov_data{k,3}=cov_data{k,2}-sum(ed & able); %misses

        cov_data{k,4}=1-cov_data{k,3}/cov_data{k,2};
    end






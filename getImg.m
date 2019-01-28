function str=getImg(D, S)

for k = 1:numel(S)
    F = fullfile(D,S(k).name);
    expression = '/home/ghezloo/Documents/ghezloo/DATAset/test/[a-z]+';
    matchStr = regexp(F,expression,'match');
    
    if ~isempty(matchStr)
        str(k) = string(matchStr) + ".jpg";
    end
end

end


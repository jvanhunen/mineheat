function testbank_eval(itestbank, H, Q, Tn, Tp, igeom)
    % Function to write or read testbank results.
    % Version 20210713 Jeroen van Hunen
    verbose = 0;
    
    filename = ['testbank/testbank_' num2str(igeom) '.mat'];
    if itestbank == -1
        savefile = filename;
        disp (['Saving testbank results to ' filename])
        Hstore = H; 
        Qstore = Q;
        Tnstore = Tn;
        Tpstore = Tp;
        save(savefile,'Hstore', 'Qstore', 'Tnstore', 'Tpstore')
    elseif itestbank == 1
        loadfile = filename;
        fprintf('   --> Tested geometry %d:', igeom)
        load(loadfile,'Hstore', 'Qstore', 'Tnstore', 'Tpstore')
        Hdiff = H - Hstore;
        Qdiff = Q - Qstore;
        Tndiff = Tn - Tnstore;
        Tpdiff = Tp - Tpstore;
        if (max(Hdiff) > 0 | max(Qdiff) > 0 | max(Tndiff) > 0 | max(Tpdiff) > 0)
            disp ([' failed: Differences in H, Q, Tn, and Tp:'])
            disp (['          max diff in H:' num2str(max(abs(Hdiff))) ])
            disp (['          max diff in Q:' num2str(max(abs(Qdiff))) ])
            disp (['          max diff in Tn:' num2str(max(abs(Tndiff))) ])
            disp (['          max diff in Tp:' num2str(max(max(abs(Tpdiff)))) ])
            if verbose
                Hdiff
                Qdiff
                Tndiff
                Tpdiff
            end
        else
            disp (' passed')
        end
    end
end
function decision_threshold_sprt = designSPRTTest(params)
	C = (1 - params.sprt_delta) * log( (1 - params.sprt_delta)/(1 - params.sprt_epsilon) ) ...
		+ params.sprt_delta * (log( params.sprt_delta/params.sprt_epsilon ));
	K = (params.sprt_tM * C) / params.sprt_mS + 1;
	An_1 = K;

	% compute A using a recursive relation:  A* = lim(n->inf)(An)
	for i = 1:10
        An = K + log(An_1);
        if (An - An_1) < 1.5e-8 
            break;
        end
        An_1 = An;
    end
	decision_threshold_sprt = An;
end
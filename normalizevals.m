function vals2 = normalizevals(vals)
mn = min(min(vals),[],2);
mx = max(max(vals),[],2);
vals2 = bsxfun(@rdivide,bsxfun(@minus,vals,mn),mx-mn);
classdef HoG

    properties (Access=private)
        bins
        binsize
        g_w
        Gauss
        ptGauss
    end
    
    methods
        function obj = HoG()
            obj.bins = 9;
            obj.binsize = (pi * 80.0) / obj.bins;
            obj.g_w = 5;
            
            obj.Gauss = zeros(obj.g_w, obj.g_w, 'single');
            a = -(obj.g_w - 1) / 2.0;
            sigma2 = 2 * (0.5 * obj.g_w) * (0.5 * obj.g_w);
            count = 0;
            for x = 0:obj.g_w
                for y = 0:obj.g_w
                    tmp = exp(-( (a+x)*(a+x)+(a+y)*(a+y) )/sigma2);
                    count = count + tmp;
                    obj.Gauss(x, y) = tmp;
                end
            end
            obj.Gauss = obj.Gauss / count;
            
            obj.ptGauss = reshape(obj.Gauss, [obj.g_w * obj.g_w, 1]);
            
        end
        
        function Iout = ExtractOBin(obj, Iorie, Imagn, off)
            desc = zeros(obj.bins, 1);
            Iout = zeros();

% 	% reset output image (border=0) and get pointers
% 	uchar** ptOut     = new uchar*[bins];
% 	uchar** ptOut_row = new uchar*[bins];
% 	for(int k=off; k<bins+off; ++k) {
% 		cvSetZero( Iout[k] );
% 		cvGetRawData( Iout[k], (uchar**)&(ptOut[k-off]));
% 	}
% 
% 	% get pointers to orientation, magnitude
% 	int step;
% 	uchar* ptOrient;
% 	uchar* ptOrient_row;
% 	cvGetRawData( Iorie, (uchar**)&(ptOrient), &step);
% 	step /= sizeof(ptOrient[0]);
% 
% 	uchar* ptMagn;
% 	uchar* ptMagn_row;
% 	cvGetRawData( Imagn, (uchar**)&(ptMagn));
% 
% 	int off_w = int(g_w/2.0); 
% 	for(int l=0; l<bins; ++l)
% 		ptOut[l] += off_w*step;
% 
% 	for(int y=0;y<Iorie->height-g_w; y++, ptMagn+=step, ptOrient+=step) {
% 
% 		// Get row pointers
% 		ptOrient_row = &ptOrient[0];
% 		ptMagn_row = &ptMagn[0];
% 		for(int l=0; l<bins; ++l)
% 			ptOut_row[l] = &ptOut[l][0]+off_w;
% 
% 		for(int x=0; x<Iorie->width-g_w; ++x, ++ptOrient_row, ++ptMagn_row) {
% 		
% 			calcHoGBin( ptOrient_row, ptMagn_row, step, desc );
% 
% 			for(int l=0; l<bins; ++l) {
% 				*ptOut_row[l] = (uchar)desc[l];
% 				++ptOut_row[l];
% 			}
% 		}
% 
% 		// update pointer
% 		for(int l=0; l<bins; ++l)
% 			ptOut[l] += step;
% 	}

        end
        
    end
    
    methods (Access=private, Static=true)
        function calcHoGBin()
        end
        
        function desc = binning(v, w, desc, maxb)
            bin1 = v;
            delta = v - bin1 - 0.5;
            if 0 > delta
                if 1 > bin1, bin2 = maxb-1; else bin2 = bin1-1; end
                delta = -delta;
            else
                if maxb-1 > bin1, bin2 = bin1+1; else bin2 = 0; end
            end
            desc(bin1) = desc(bin1) + (1-delta)*w;
            desc(bin2) = desc(bin1) + delta*w;
        end
        
    end
    
end

% inline void HoG::calcHoGBin(uchar* ptOrient, uchar* ptMagn, int step, double* desc) {
% 	for(int i=0; i<bins;i++)
% 		desc[i]=0;
% 
% 	uchar* ptO = &ptOrient[0];
% 	uchar* ptM = &ptMagn[0];
% 	int i=0;
% 	for(int y=0;y<g_w; ++y, ptO+=step, ptM+=step) {
% 		for(int x=0;x<g_w; ++x, ++i) {
% 			binning((float)ptO[x]/binsize, (float)ptM[x] * ptGauss[i], desc, bins);
% 		}
% 	}
% }
% 
% inline void HoG::binning(float v, float w, double* desc, int maxb) {
% 	int bin1 = int(v);
% 	int bin2;
% 	float delta = v-bin1-0.5f;
% 	if(delta<0) {
% 		bin2 = bin1 < 1 ? maxb-1 : bin1-1; 
% 		delta = -delta;
% 	} else
% 		bin2 = bin1 < maxb-1 ? bin1+1 : 0; 
% 	desc[bin1] += (1-delta)*w;
% 	desc[bin2] += delta*w;
% }


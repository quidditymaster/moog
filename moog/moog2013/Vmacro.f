
      real*8 function vmacro (xprofile)
c******************************************************************************
c     This routine computes, by linear interpolation, a point along a 
c     radial-tangential macroturbulence profile.  This routine was written by 
c     Suchitra Balachandran, and is based on the work of Gray 1992, in
c     "The Obs. & Anal. of Stell. Phot", p. 409.  These functions have 
c     been computed and included in the data arrays below:  
c             xrt = velocity / zeta_RT 
c             yrt = value at xrt  
c     The area under the function is normalized to unity
c******************************************************************************

      implicit real*8 (a-h,o-z)
      real*8 xrt(250), yrt(250)
c
      data (xrt(l),l=1,171)/
     . 0.0001,0.0101,0.0201,0.0301,0.0401,0.0501,0.0601,0.0701,0.0801,
     . 0.0901,0.1001,0.1101,0.1201,0.1301,0.1401,0.1501,0.1601,0.1701,
     . 0.1801,0.1901,0.2001,0.2101,0.2201,0.2301,0.2401,0.2501,0.2601,
     . 0.2701,0.2801,0.2901,0.3001,0.3101,0.3201,0.3301,0.3401,0.3501,
     . 0.3601,0.3701,0.3801,0.3901,0.4001,0.4101,0.4201,0.4301,0.4401,
     . 0.4501,0.4601,0.4701,0.4801,0.4901,0.5001,0.5101,0.5201,0.5301,
     . 0.5401,0.5501,0.5601,0.5701,0.5801,0.5901,0.6001,0.6101,0.6201,
     . 0.6301,0.6401,0.6501,0.6601,0.6701,0.6801,0.6901,0.7001,0.7101,
     . 0.7201,0.7301,0.7401,0.7501,0.7601,0.7701,0.7801,0.7901,0.8001,
     . 0.8101,0.8201,0.8301,0.8401,0.8501,0.8601,0.8701,0.8801,0.8901,
     . 0.9001,0.9101,0.9201,0.9301,0.9401,0.9501,0.9601,0.9701,0.9801,
     . 0.9901,1.0001,1.0101,1.0201,1.0301,1.0401,1.0501,1.0601,1.0701,
     . 1.0801,1.0901,1.1001,1.1101,1.1201,1.1301,1.1401,1.1501,1.1601,
     . 1.1701,1.1801,1.1901,1.2001,1.2101,1.2201,1.2301,1.2401,1.2501,
     . 1.2601,1.2701,1.2801,1.2901,1.3001,1.3101,1.3201,1.3301,1.3401,
     . 1.3501,1.3601,1.3701,1.3801,1.3901,1.4001,1.4101,1.4201,1.4301,
     . 1.4401,1.4501,1.4601,1.4701,1.4801,1.4901,1.5001,1.5101,1.5201,
     . 1.5301,1.5401,1.5501,1.5601,1.5701,1.5801,1.5901,1.6001,1.6101,
     . 1.6201,1.6301,1.6401,1.6501,1.6601,1.6701,1.6801,1.6901,1.7001/
      data (xrt(l),l=172,250)/
     . 1.7101,1.7201,1.7301,1.7401,1.7501,1.7601,1.7701,1.7801,1.7901,
     . 1.8001,1.8101,1.8201,1.8301,1.8401,1.8501,1.8601,1.8701,1.8801,
     . 1.8901,1.9001,1.9101,1.9201,1.9301,1.9401,1.9501,1.9601,1.9701,
     . 1.9801,1.9901,2.0001,2.0101,2.0201,2.0301,2.0401,2.0501,2.0601,
     . 2.0701,2.0801,2.0901,2.1001,2.1101,2.1201,2.1301,2.1401,2.1501,
     . 2.1601,2.1701,2.1801,2.1901,2.2001,2.2101,2.2201,2.2301,2.2401,
     . 2.2501,2.2601,2.2701,2.2801,2.2901,2.3001,2.3101,2.3201,2.3301,
     . 2.3401,2.3501,2.3601,2.3701,2.3801,2.3901,2.4001,2.4101,2.4201,
     . 2.4301,2.4401,2.4501,2.4601,2.4701,2.4801,2.4901/
c
      data (yrt(l),l=1,133)/
     . 1.128380,1.126790,1.088790,1.069200,1.049990,1.031020,1.012720,
     . 0.993719,0.975411,0.957327,0.939467,0.921830,0.904416,0.887224,
     . 0.870264,0.853520,0.836978,0.820671,0.805960,0.788712,0.773060,
     . 0.757624,0.742405,0.727394,0.712603,0.698026,0.683659,0.669504,
     . 0.655559,0.641822,0.628292,0.614969,0.601851,0.588936,0.576224,
     . 0.563713,0.551402,0.539288,0.527372,0.515651,0.504123,0.492788,
     . 0.481644,0.470689,0.459921,0.449339,0.438813,0.428727,0.418693,
     . 0.408839,0.399161,0.389660,0.382276,0.371177,0.362193,0.353376,
     . 0.344727,0.336242,0.327921,0.319760,0.311759,0.303916,0.296228,
     . 0.288693,0.281342,0.273786,0.266697,0.260087,0.253292,0.246640,
     . 0.240128,0.233754,0.227516,0.221413,0.215442,0.209602,0.203891,
     . 0.198305,0.192845,0.187508,0.182291,0.177193,0.172213,0.167347,
     . 0.162595,0.157955,0.153423,0.149000,0.144683,0.140469,0.136358,
     . 0.132347,0.128434,0.124619,0.120898,0.117271,0.113735,0.110289,
     . 0.106931,0.103659,0.100472,0.097368,0.094346,0.091403,0.088538,
     . 0.085750,0.083037,0.080397,0.077829,0.075331,0.072902,0.070540,
     . 0.068244,0.066012,0.063844,0.061736,0.059689,0.057701,0.055770,
     . 0.053895,0.052075,0.050308,0.048594,0.046930,0.045317,0.043751,
     . 0.042233,0.040761,0.039334,0.037951,0.036611,0.035316,0.034058/
      data (yrt(l),l=134,250)/
     . 0.032839,0.031659,0.030516,0.029410,0.028339,0.027303,0.026300,
     . 0.025330,0.024392,0.023484,0.022607,0.021759,0.020939,0.020147,
     . 0.019382,0.018643,0.017928,0.017239,0.016573,0.015930,0.015309,
     . 0.014711,0.014133,0.013576,0.013038,0.012520,0.012021,0.011539,
     . 0.011075,0.010627,0.010196,0.009781,0.009381,0.008996,0.008626,
     . 0.008269,0.007925,0.007595,0.007277,0.006972,0.006678,0.006395,
     . 0.006123,0.005862,0.005611,0.005369,0.005138,0.004915,0.004701,
     . 0.004496,0.004299,0.004110,0.003929,0.003755,0.003588,0.003428,
     . 0.003274,0.003127,0.002986,0.002850,0.002721,0.002597,0.002478,
     . 0.002364,0.002255,0.002151,0.002051,0.001955,0.001864,0.001776,
     . 0.001692,0.001612,0.001536,0.001463,0.001393,0.001326,0.001262,
     . 0.001201,0.001143,0.001087,0.001034,0.000984,0.000935,0.000889,
     . 0.000845,0.000803,0.000763,0.000725,0.000689,0.000654,0.000621,
     . 0.000590,0.000560,0.000531,0.000504,0.000478,0.000454,0.000430,
     . 0.000408,0.000387,0.000366,0.000347,0.000329,0.000312,0.000295,
     . 0.000280,0.000265,0.000251,0.000237,0.000224,0.000212,0.000201,
     . 0.000190,0.000180,0.000170,0.000161,0.000152/
     
 
      if (xprofile.lt.xrt(1) .or. xprofile.ge.xrt(250)) then
         vmacro = 0.
         return
      endif

      i = int(100.*xprofile) + 1
      vmacro = (yrt(i+1)-yrt(i))*(xprofile-xrt(i))/(xrt(i+1)-xrt(i)) 
     .         + yrt(i) 


      return
      end



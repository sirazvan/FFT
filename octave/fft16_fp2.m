function [Zr, Zi, dynamic_scale] = fft16_fp2(zr, zi, direct, width);


  %% zr and zi must be scaled such that zr.^2+zi.^2 < R = 2^(width-1).

  %% For example, for width = 16, R = 2^15 and zr and zi should be
  %% smaller than 2^15/sqrt(2) = 23171. However, scaling is best
  %% chosen as a power of 2, in our case 2^14 = 16384. 
  
  %%width = 8/16/24/32

  %%B = 2^width, used only for documentation

  %% Unsigned integers, values in [0...B-1]
  
  %% Using 2's complement, with values in [-B/2 ... B/2-1] = [-R .. R-1]. 
  
  R = 2^(width-1);  %% R = B/2

  

  %% How should we approximate the roots of unity (cos+i sin) in fixed
  %% point?

  %% If we scale with R=B/2, there is no 1 (should be +R, but max
  %%pozitive value is R-1).
  %%
  %% Solution: works with scaling R, as we never multiply by 1 as a
  %%root (nor by -1, j or -j)
 
  
  sq2_half = floor(sqrt(2)/2 * R + 0.5);
  c = floor(cos(pi/8) * R + 0.5);
  s = floor(sin(pi/8) * R + 0.5);


  assert(length(zr)==16);
  assert(length(zi)==16);


  rounding = 0;  %%1 if true, 0 if false (implies chopping)

  clear j;

  %% For inverse transform, everything remains the same but input z is
  %% conjugated and at the end output is conjugated.


  if(direct == false)
    zi = -zi;
  end
    
  z4 = zr + j*zi;

				%  if (direct == false)
				%    z4 = zz(br+1);
				%   else
%    z4 = zz;
%  end
  
  
  %% from level 4 to level 3
  
  %% 8 x type 1
  
  z3(1:8)  = z4(1:8) + z4(9:16);
  z3(9:16) = z4(1:8) - z4(9:16);


  %%disp("Level 1")
  max(max(abs(real(z3))),max(abs(imag(z3))));
  
  
  %% from level 3 to level 2
  
  %% 4 x type 1
  z2(1:4) = z3(1:4)    + z3(5:8);
  z2(5:8) = z3(1:4)    - z3(5:8);

  %% 4 x type 2
  z2(9:12)  = z3(9:12) - j*z3(13:16);
  z2(13:16) = z3(9:12) + j*z3(13:16);

  %%disp("Level 2")
  max(max(abs(real(z2))),max(abs(imag(z2))));
  

%%  z2 = floor(z2/4);

  %% from level 2 to level 1

  %% 2 x type 1
  z1(1:2) = z2(1:2) + z2(3:4);
  z1(3:4) = z2(1:2) - z2(3:4);

  %% 2 x type 2
  z1(5:6) = z2(5:6) - j*z2(7:8);
  z1(7:8) = z2(5:6) + j*z2(7:8);

  %% 2 type 3 cu flag 0
  z1(9:10)  = z2(9:10) - floor(sq2_half*(-1+j)*z2(11:12)/(R)+0.5*rounding);
  z1(11:12) = z2(9:10) + floor(sq2_half*(-1+j)*z2(11:12)/(R)+0.5*rounding);

  %% 2 type 3 cu flag 1
  z1(13:14) = z2(13:14) - floor(sq2_half*(1+j)*z2(15:16)/(R)+0.5*rounding);
  z1(15:16) = z2(13:14) + floor(sq2_half*(1+j)*z2(15:16)/(R)+0.5*rounding);

  %%disp("Level 1")
  max(max(abs(real(z1))),max(abs(imag(z1))));
   
  %% from level 1 to level 0

  %% 1 x type 1
  z0(1) = z1(1) + z1(2);
  z0(2) = z1(1) - z1(2);

  %% 1 x type 2
  z0(3) = z1(3) - j*z1(4);
  z0(4) = z1(3) + j*z1(4);

  %% 1 x type 3 cu flag 0  
  z0(5) = z1(5) - floor(sq2_half*(-1+j)*z1(6)/(R)+0.5*rounding);
  z0(6) = z1(5) + floor(sq2_half*(-1+j)*z1(6)/(R)+0.5*rounding);

   %% 1 type 3 cu flag 1
  z0(7) = z1(7) - floor(sq2_half*(1+j)*z1(8)/(R)+0.5*rounding);
  z0(8) = z1(7) + floor(sq2_half*(1+j)*z1(8)/(R)+0.5*rounding);


  %% 4 type 4 cu diverse twiddle (a,b)
  z0(9)  = z1(9)  - floor((-c+j*s)*z1(10)/(R)+0.5*rounding);
  z0(10) = z1(9)  + floor((-c+j*s)*z1(10)/(R)+0.5*rounding);

  z0(11) = z1(11)  - floor((s+j*c)*z1(12)/(R)+0.5*rounding);
  z0(12) = z1(11)  + floor((s+j*c)*z1(12)/(R)+0.5*rounding);

  
  z0(13) = z1(13)  - floor((-s+j*c)*z1(14)/(R)+0.5*rounding);
  z0(14) = z1(13)  + floor((-s+j*c)*z1(14)/(R)+0.5*rounding);

  
  z0(15) = z1(15) - floor((c+j*s)*z1(16)/(R)+0.5*rounding);
  z0(16) = z1(15) + floor((c+j*s)*z1(16)/(R)+0.5*rounding);

  %%disp("Level 0")
  final = max(max(abs(real(z0))),max(abs(imag(z0))));

  dynamic_scale = max(0,length(dec2bin(final))-length(dec2bin(R/2)));
  

  z0 = floor(z0/2^dynamic_scale+0.5*rounding);
  
  %% Bit reversed order for array index starting from 0

  br = [0    8    4   12    2   10    6   14    1    9    5   13    3   11    7   15];
  br = br + 1;
  
  
  Z = z0(br);

  Zr = real(Z);

  if(direct == true)
    Zi = imag(Z);
  else
    Zi = -imag(Z);
  end
   
 
end


%!test
%! scale = 2^14;
%! z = 2*rand(1,16)-1+j*(2*rand(1,16)-1);
%! z_fp = floor(real(z)*scale+0.5)+j*floor(imag(z)*scale+0.5);
%! [Zr, Zi, dynamic_scale] = fft16_fp2(real(z_fp), imag(z_fp), true, 16);
%! disp("dynamic_scale fft direct")
%! disp(dynamic_scale);
%! Z_octave = fft(z)/2^dynamic_scale;
%! Zr_octave = floor(real(Z_octave)*scale+0.5);
%! Zi_octave = floor(imag(Z_octave)*scale+0.5);
%! (Zr-Zr_octave)
%! (Zi-Zi_octave)
%! assert(max(Zr - Zr_octave) <= 2)
%! assert(max(Zi - Zi_octave) <= 2)
%! [Z_inv_r, Z_inv_i, dynamic_scale] = fft16_fp2(real(z_fp), imag(z_fp), false, 16);
%! disp("dynamic_scale fft inverse")
%! disp(dynamic_scale);
%! Z_inv_octave = ifft(z)*16/2^dynamic_scale;
%! Z_inv_r_octave = floor(real(Z_inv_octave)*scale+0.5);
%! Z_inv_i_octave = floor(imag(Z_inv_octave)*scale+0.5);
%! (Z_inv_r-Z_inv_r_octave)
%! (Z_inv_i-Z_inv_i_octave)
%! assert(max(Z_inv_r - Z_inv_r_octave) <= 2)
%! assert(max(Z_inv_i - Z_inv_i_octave) <= 2)




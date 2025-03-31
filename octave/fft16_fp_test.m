clear all;

R = 2^15;
scale = 2^14;


cnt = 1;
ds_max = 0;

for k=1:100
  z = 2*rand(1,16)-1+j*(2*rand(1,16)-1);

  z2 = 2*rand(1,16)-1+j*(2*rand(1,16)-1);


  
  z_fp = floor(real(z)*scale+0.5)+j*floor(imag(z)*scale+0.5);
  
  [Zr, Zi, dynamic_scale1] = fft16_fp2(real(z_fp), imag(z_fp), true, 16);
  
  Z_octave = fft(z)/2^dynamic_scale1;
  Zr_octave = floor(real(Z_octave)*scale+0.5);
  Zi_octave = floor(imag(Z_octave)*scale+0.5);
  
  (Zr-Zr_octave);
  (Zi-Zi_octave);
  assert(max(Zr - Zr_octave) <= 4)
  assert(max(Zi - Zi_octave) <= 4)
  
  
  
 
  z2_fp = floor(real(z2)*scale+0.5)+j*floor(imag(z2)*scale+0.5);
  
  [Z2r, Z2i, dynamic_scale2] = fft16_fp2(real(z2_fp), imag(z2_fp), true, 16);
  
  Z2_octave = fft(z2)/2^dynamic_scale2;
  Z2r_octave = floor(real(Z2_octave)*scale+0.5);
  Z2i_octave = floor(imag(Z2_octave)*scale+0.5);
  
  (Z2r-Z2r_octave);
  (Z2i-Z2i_octave);
  assert(max(Z2r - Z2r_octave) <= 4)
  assert(max(Z2i - Z2i_octave) <= 4)
  
  
  
  
  Z12 =  floor((Zr+j*Zi).*(Z2r+j*Z2i)/scale+0.5);
  
  
  
  
  [z12_r, z12_i, dynamic_scale3] = fft16_fp2(real(Z12), imag(Z12), false, 16);
  
  z12_octave=ifft(fft(z).*fft(z2));
  
  
  final_scale = dynamic_scale1 + dynamic_scale2 + dynamic_scale3;
  
  
  
  z12_octave_r =   floor(real(z12_octave)*scale*2^(-final_scale+4)+0.5);
  z12_octave_i =   floor(imag(z12_octave)*scale*2^(-final_scale+4)+0.5);
  
  
  
  err_max = max(max( z12_octave_r-z12_r), max(z12_octave_i-z12_i));
  
  err_rel = err_max/max(max(abs(z12_r),max(abs(z12_i))));
  
  snr = 20*log10(err_rel);
  
  
  er(k) = err_rel;

  ds(3*k+1) = dynamic_scale1;
  ds(3*k+2) = dynamic_scale2;
  ds(3*k+3) = dynamic_scale3;

  fs(k) = final_scale;
  

  if (err_rel > 0.7e-3)
    z_save(cnt,:)=z;
    z2_save(cnt,:)=z2;
    cnt = cnt + 1;
  end

  if (dynamic_scale1 > ds_max)
    ds_max = dynamic_scale1;
  end

end

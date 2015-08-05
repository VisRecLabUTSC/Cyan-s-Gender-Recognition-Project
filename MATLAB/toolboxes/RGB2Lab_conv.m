
%%%1. Convert from (monitor-specific) non-standard RGB color profile to device-independent
%%%XYZ profile (ICC input profile must include MatTRC conversion values).
%%%ICC file used displayed in Syst Pref - Display - Color - Open Profile
%%%(window title) and found (usually) in drive/Library/ColorSync/Profiles/Displays
%%%2. Then convert from xyz to lab
%%%[Alternatively conv from sRGB to lab - likely small diffs if typical monitor]
%%%3. Convert uint8 scaled vals to double (for actual Lab intervals)

function [im_lab] = RGB2Lab_conv (im_rgb)

if nargin==0
    im_rgb = imread('peppers.png');
    imtool(im_rgb)
    %im_rgb=uint8(ones(4,4,3)*127);
end


fl_nm='color_profiles/lab_mac_0412/Color LCD-00000610-0000-9CA3-0000-0000042728C2.icc';
%fl_nm='color_profiles/pers_mac_0412/Color LCD-00000610-0000-9CB7-0000-000004272DC2.icc';
InputProfile = iccread(fl_nm);
cform_rgb2xyz = makecform('mattrc',InputProfile.MatTRC, ...
              'direction', 'forward');
cform_xyz2lab = makecform('xyz2lab');
im_xyz = applycform(im_rgb, cform_rgb2xyz);
im_lab_uint8 = applycform(im_xyz, cform_xyz2lab);
im_lab=lab2double(im_lab_uint8);
%vals_tst_labmac=[im_lab(1:3, 1:3, 1) im_lab(1:3, 1:3, 2) im_lab(1:3,1:3, 3)]

% cform_lab2srgb = makecform('lab2srgb');    
% im_back = applycform(im_lab,cform_lab2srgb);
% imtool(uint8(im_back*255))


% cform_srgb2lab = makecform('srgb2lab');
% im_lab_uint8 = applycform(im_rgb, cform_srgb2lab);
% im_lab=lab2double(im_lab_uint8);
% vals_tst_srgb=[im_lab(1:3, 1:3, 1) im_lab(1:3, 1:3, 2) im_lab(1:3,1:3, 3)]

% im_lab=RGB2Lab(im_rgb);
% vals_tst_old=[im_lab(1:3, 1:3, 1) im_lab(1:3, 1:3, 2) im_lab(1:3,1:3, 3)]
          
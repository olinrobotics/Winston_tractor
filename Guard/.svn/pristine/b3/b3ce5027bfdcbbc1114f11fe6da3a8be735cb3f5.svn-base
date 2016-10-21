function img = pbGetImg(pb)
steps = pb.getSteps();
strides = pb.getStrides();
layers = pb.getLayers();
img = pb.getData().toByteArray();
img = reshape(typecast(img, 'uint8'), steps, strides, layers);
end

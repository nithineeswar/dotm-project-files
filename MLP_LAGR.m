clc;
clear all;
close all;

% dbstop in C:\Users\nithine\Documents\MATLAB\FP\afnn_matrix.m at 14;

feature = 'color_ltp';
feature_l = 6;

in_arg = feature_l;
hidden_layers = 1;
hidden_neurons = 25;
out_arg = 1;
network = afnn_matrix(in_arg, hidden_layers, hidden_neurons, out_arg);
first_HL_eta_const = 0.0001; 
network.act_func = 'tanh';

samples = 3600;
fid = fopen(['E:\Datasets\Experimentation\LAGR DS3B\MLP training data\' feature '.trn'], 'rb');
training_data = fread(fid, [samples feature_l+1], '*double');
fclose(fid);

fid = fopen(['E:\Datasets\Experimentation\LAGR DS3A\MLP training data\' feature '.trn'], 'rb');
data = fread(fid, [samples feature_l+1], '*double');
fclose(fid);

% image_base = 'block';
% [block_size, blocks, r_l, c_l] = get_block_size(0);
% result_path = [main_dir '\' dataset '\' 'subsampled training dataset\result\' image_base '_based\' 'MLP' '\' feature '\']% blocks '\']

% [training_data, validation_data, test_data] = prepare_data(data);
test_data = zeros(feature_l+1, samples/2);
validation_data = zeros(feature_l+1, samples/2);

for i = 1:samples
    if mod(i, 2)
        validation_data(:, floor(i/2)+1) = data(i, :)';
    else
        test_data(:, i/2) = data(i, :)';
    end
end
    
display([feature ',' num2str(in_arg) ' input, ' num2str(hidden_neurons) ' neurons ' 'in each of the ' num2str(hidden_layers) ' layers']);

epoch = 0;
e_tr = 10;
e_va = 11;

tr_data_l = samples;%size(training_data);
va_data_l = size(validation_data);

training_data = training_data';

tic
while e_va > 0.095 && epoch < 251
    index = randperm(tr_data_l);
%     index = ceil(tr_data_l * rand(1, tr_data_l));
    e_tr = 0;
    valid_samples = 0;
    epoch = epoch+1;
    for i = 1:tr_data_l
        j = index(1, i);
        if abs(training_data(feature_l+1, j))
            valid_samples = valid_samples + 1;
            network.input = training_data(1:feature_l, j);
            network = network.forward_pass();
            diff = training_data(feature_l+1, j) - network.output.a_out;
%             [i diff]
            network = network.back_propagate(diff);
            network = network.weight_update(first_HL_eta_const);
            e_tr = e_tr + sum(diff.^2);
        end
    end
    
    e_tr = e_tr/(2*valid_samples);
    E_tr_avg(epoch, 1) = e_tr;

    valid_samples = 0;
        e_va = 0;
        for i = 1:va_data_l(1,2)
            if abs(validation_data(feature_l+1, i))
                valid_samples = valid_samples + 1;
                network.input = validation_data(1:feature_l, i);
                network = network.forward_pass();
                diff = validation_data(feature_l+1, i) - network.output.a_out;
                e_va = e_va + sum(diff.^2);
            end
        end
        e_va = e_va/(2*valid_samples);
        E_va_avg(epoch, 1) = e_va;
    obj(epoch) = network;
    display([epoch e_tr e_va]);
end
toc

plot(1:epoch-1, [E_tr_avg(1:epoch-1) E_va_avg(1:epoch-1)], '.-')
grid on;

% index = epoch;
[m, index] = min(E_va_avg);
network = obj(index);

e_tst = 0;
network_out = zeros(1, va_data_l(1, 2));

valid_samples = 0;
for i = 1:samples/2
    if abs(test_data(feature_l+1, i))
        valid_samples = valid_samples+1;
        network.input = test_data(1:feature_l, i);
        network = network.forward_pass();
        if network.output.a_out > 0
            network_out(1, i) = 1;
        else
            network_out(1, i) = -1;
        end
        diff = test_data(feature_l+1, i) - network.output.a_out;
        e_tst = e_tst + sum(diff.^2);
    else
        network_out(1, i) = 0;
    end
end
e_tst_avg = e_tst/(2*valid_samples);

label = test_data(feature_l+1, :);
result = network_out;

true_label = double(label > 0);
false_label = double(label < 0);

total_valid_label = sum(sum(abs(label)));
accuracy_mat = double(result == label) .* double(abs(label));
total_correct_result = sum(sum(accuracy_mat));
accuracy = total_correct_result / total_valid_label * 100;

recall = sum(double(result == true_label).* true_label) / sum(double(abs(true_label)))*100;
false_positive = sum(double(result == 1).* false_label) / sum(double(abs(false_label)))*100;

[accuracy; recall; false_positive]
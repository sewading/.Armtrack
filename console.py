import numpy as np
# from io import StringIO
# import pandas as pd
import tensorflow as tf
# import tensorflow_datasets as tfds
from tensorflow import keras
from tensorflow.keras import backend as K

batch_size=1024
test_data_ratio=.2

class Mk1(tf.keras.Model):
    def __init__(self):
        super(Mk1, self).__init__()
        self.rnn=tf.keras.layers.LSTM(3,return_sequences='true',activation='sigmoid')
        self.rnn2=tf.keras.layers.LSTM(9,return_sequences='true',activation='sigmoid')
        self.dense1=tf.keras.layers.Dense(3,activation='sigmoid')

    def call(self,inputs):
        x1,x2,x3=tf.split(inputs,num_or_size_splits=3,axis=2)
        # print('*****x1:',x1.get_shape)
        # print('**********x2:',x2.get_shape)
        # print('********************x3:',x3.get_shape)
        y1=self.rnn(x1)
        y2=self.rnn(x2)
        y3=self.rnn(x3)
        # print('********************y1:',y1.get_shape)
        # print('*************************y2:',y2.get_shape)
        # print('******************************y3:',y3.get_shape)
        y4=tf.concat([y1,y2,y3],axis=2)
        # print('***********************************y4:',y4.get_shape)
        y5=self.rnn2(y4)
        # print('***********************************y4:',y4.get_shape)
        y = self.dense1(y5)
        return y
    
# def custom_loss(x,y):
#     print ('*****************************************')
#     print (x.get_shape())
#     print(x[0])
#     theta1=2*np.arccos(x[0])
#     theta2=2*np.arccos(y[0])
#     k1=np.sin(theta1/2)
#     k2=np.sin(theta2/2)
#     x1=[0,0,0]
#     x2=[0,0,0]
#     if k1:
#         x1=[o/k1 for o in x[1:4]]
#         x1=[o1/(sum([o2**2 for o2 in x1])**.5) for o1 in x1]
#     if k2:
#         x2=[o/k1 for o in y[1:4]]
#         x2=[o1/(sum([o2**2 for o2 in x2])**.5) for o1 in x2]
#     s=0
#     for o1 in [0,1,2]:
#         s=s+(x1[o1]-x2[o1])**2
#     return s*.5

# x=np.genfromtxt('.\watch_data.csv',delimiter=",",skip_header=1)
# x=np.concatenate((x[:,range(9,15)],x[:,range(18,21)]),axis=1)
# y=np.genfromtxt('.\oculus_data.csv',delimiter=",",skip_header=1)

# N=min(len(x),len(y))
# x=np.delete(x,range((N//batch_size)*batch_size,len(x)),axis=0)
# y=np.delete(y,range((N//batch_size)*batch_size,len(y)),axis=0)

# y1=y[:,range(1,4)] #position groundtruth
# y2=y[:,range(4,8)] #rotation groundtruth
    
# x=np.split(x,batch_size)
# y=np.split(y,batch_size)
# y1=np.split(y1,batch_size)
# y2=np.split(y2,batch_size)
# x=tf.convert_to_tensor(x, np.float32)
# y=tf.convert_to_tensor(y, np.float32)
# y1=tf.convert_to_tensor(y1, np.float32)
# y2=tf.convert_to_tensor(y2, np.float32)

X=np.genfromtxt('.\\test.txt',delimiter=",")

x=X[:,range(1,10)]
y_ori=X[:,range(13,16)]

x=np.split(x,batch_size)
y_ori=np.split(y_ori,batch_size)
x=np.array(x)
y_ori=np.array(y_ori)
xt=x[:,int(np.shape(x)[1]-(np.shape(x)[1]*test_data_ratio)):np.shape(x)[1],:]
yt_ori=y_ori[:,int(np.shape(y_ori)[1]-(np.shape(y_ori)[1]*test_data_ratio)):np.shape(y_ori)[1],:]
x=tf.convert_to_tensor(x, np.float32)
y_ori=tf.convert_to_tensor(y_ori, np.float32)
xt=tf.convert_to_tensor(xt, np.float32)
yt_ori=tf.convert_to_tensor(yt_ori, np.float32)

nn=Mk1()
nn.compile(optimizer="Adam", loss='mse') 
#改成custom loss，找一个acc

# x1=tf.random.normal([10,100,3])
# x2=tf.random.normal([10,100,3])
# x3=tf.random.normal([10,100,3])
# xt=tf.concat([x1,x2,x3],2)
# yt=tf.random.normal([10,100,4])

nn.fit(x,y_ori,epochs=100)

# nn.predict(xt)

# test module

results = nn.evaluate(xt, yt_ori)

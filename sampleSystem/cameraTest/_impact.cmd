setMode -bs
setMode -bs
setCable -port auto
Identify 
identifyMPM 
assignFile -p 2 -file "/afs/athena.mit.edu/user/other/t_bohlen/projects/climber/sampleSystem/cameraTest/zbt_6111_sample.bit"
Program -p 2 
assignFile -p 2 -file "/afs/athena.mit.edu/user/other/t_bohlen/projects/climber/sampleSystem/cameraTest/zbt_6111_sample.bit"
Program -p 2 
saveProjectFile -file "/afs/athena.mit.edu/user/other/t_bohlen/projects/climber/sampleSystem/cameraTest/cameraTest.ipf"
setMode -bs
deleteDevice -position 3
deleteDevice -position 2
deleteDevice -position 1

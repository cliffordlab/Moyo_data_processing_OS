## Table of Contents
1. [Moyo_data_processing_OS](#1-moyo-data-processing-OS)
2. [About the data](#2-about-the-data)
3. [Data Format](#3-data-format)
    1. [Accelerometer file](#31-accelerometer-file) 
    2. [Location file](#32-location-file) 
    3. [Weight file](#33-weight-file) 
    4. [Charging file](#34-charging-file) 
    5. [Sms file](#35-sms-file) 
    6. [Places file](#36-places-file) 
    7. [Call file](#37-call-context) 
    8. [Weather file](#38-weather-context) 
    9. [Survey files](#39-survey-context) 
4. [Data Processiong](#4-data-processing)
5. [3rd Party APIs](#5-3rd-party-apis)

# 1. Moyo data processing OS
Open Source Repository of Code to Parse Data Generated by Moyo App

# 2. About the data
The data collected by the AMoSS mobile app is information about activity, location context, and social networking.

# 3. Data Format 
Storage path in s3 will be **"amoss-mhealth/study/10-digit-id/startOfWeek millis/data_file"** the subfolder will be created every week set by whenever a users phone passing the threshold of monday at 10am for whatever timezone they are currently in

## 3.1. Accelerometer file
1. <b>File Name:</b> unix_time_stamp with 1 digit dropped with .acc extension (example: 495597707.acc)
2. <b>Header:</b> "time,x,y,z"

## 3.2. Location file
1. <b>File Name:</b> offset on location 20 degress on long and lat .loc extension (example: location.loc) will need to change to 495597707.loc because sub folders are change to weekly every monday at 10am instead of daily
2. <b>Header:</b> "time,latitude,longitude"

## 3.3. Weight file
1. <b>File Name:</b> .wt extension (example: weight.wt) for same reason as location file will change to 495597707.weight
2. <b>Header:</b> "weight/lbs,date"

## 3.4. Charging file
1. <b>File Name:</b> will updated every time a user charge to phone .txt extension (example: charging.txt) for same reason as location file will change to 495597707.charging
2. <b>Header:</b> "is_charging,time"

## 3.5. Sms file
1. <b>File Name:</b> counts how many time a message has words from a category in liwc .sms extension (example: socact.sms) for same reason as location file will change to 495597707.sms
2. <b>Header:</b> "category/meta=value"
3. <b>Key Info:</b> for key "type" the values are 

Value | Meaning |
--- | --- |
0 | type all
1 | type inbox
2 | type sent
3 | type draft
4 | type outbox
5 | type failed
6 | type queued

## 3.6. Call file
1. <b>File Name:</b> .call extension (example: socact_call.call) for same reason as location file will change to 495597707.call
2. <b>Header:</b> "hashed-ph-number,call-type,call-date,call-duration"
3. Call duration is in seconds

## 3.7. Places file
1. <b>File Name:</b> make requests to google api's for location context information such as restaurants and whatever establishments are around .csv extension (example: Places.csv) for same reason as location file will change to 495597707.places
2. <b>Header:</b> "Timestamp,Name,Address,Estab.#,Likelihood"

## 3.8. Weather file
1. <b>File Name:</b> make requests to google api's for weather information .csv extension (example: Weather.csv) for same reason as location file will change to 495597707.weather
2. <b>Header:</b> "Timestamp,Temperature,Feels Like,Dew,Humidity,Cond#"

## 3.9. Survey files
File extensions | type |
--- | --- |
mz | mood zoom survey
ms | mood swipe survey
acc | accelerometer
phq | phq9 survey
sms | default sms app data
call | call data
weather | google api weather
places | google api places
weight | participants inputted weight
charge | every time participant plugs in or out phone
dismiss | when participant dismissed a survey notification
tz | records changes in timezone
kccq | kccq survey

###**Mood Zoom**
Filename e.g. `495597707.mz`

`Header Values` | Question | Answer  |
--- | --- | --- |
1 | Anxious | 1-7 low to high
2 | Elated | 1-7 low to high
3 | Sad | 1-7 low to high
4 | Angry | 1-7 low to high
5 | Irritable | 1-7 low to high
6 | Energetic | 1-7 low to high
7 | What was the main cause of your stress today? | 0-6

Mood Zoom Question 6  `#` | Answer |
--- | --- |
0 | no answer
1 | health
2 | work/study
3 | money
4 | relationship
5 | family
6 | other
Example File:

```
0,1,2,3,4,5,6
1,1,1,1,2,3,4
```

If multiple answers or chosen input will have multiple numbers e.g. `123`

###**Mood Swipe**
Filename e.g. `495597707.ms`

Mood Swipe Key | MoodSwipe Value |
--- | --- |
1 | angry
2 | sad
3 | neutral
4 | happy
5 | excited

Example File:

```
Mood
3
```

###**PHQ9**

Filename e.g. `495597707.phq`

 Question Key | Question Value |
--- | --- |
0 | Little interest or pleasure in doing things
1 | Feeling down, depressed, or hopeless
2 | Trouble falling or staying asleep, or sleeping too much
3 | Feeling tired or having little energy
4 | Poor appetite or overeating
5 | Feeling bad about yourself or that you are a failure or have let yourself or your family down
6 | Trouble concentrating on things, such as reading the newspaper or watching television
7 | Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual
8 | Thoughts that you would be better off dead or of hurting yourself in some way

Answer Key | Answer Value |
--- | --- |
0 | Not at all
1 | Several days
2 | More than half the days
3 | Nearly every day

Example File:

```
Question,Answer
0,1
1,2
2,3
3,0
4,0
5,0
6,2
7,1
8,1
```

###**KCCQ**
Filename e.g. `495597707.kccq`

 Question Key | Question Value |
--- | --- |
1 | Heart failure affects different people in different ways. Some feel shortness of breath while others feel fatigue. Please indicate how much you are limited by heart failure (shortness of breath or fatigue) in your ability to do the following activities over the past 2 weeks.
2 | Over the past 2 weeks, how many times did you have swelling in your feet, ankles or legs when you woke up in the morning?
3 | Over the past 2 weeks, on average, how many times has fatigue limited your ability to do what you wanted?
4 | Over the past 2 weeks, on average, how many times has shortness of breath limited your ability to do what you wanted?
5 | Over the past 2 weeks, on average, how many times have you been forced to sleep sitting up in a chair or with at least 3 pillows to prop you up because of shortness of breath?
6 | Over the past 2 weeks, how much has your heart failure limited your enjoyment of life?
7 | If you had to spend the rest of your life with your heart failure the way it is right now, how would you feel about this?
8 | How much does your heart failure affect your lifestyle? Please indicate how your heart failure may have limited your participation in the following activities over the past 2 weeks.

Answer Key Q1 | Answer Value Q1 |
--- | --- |
1 | Extremely Limited
2 | Quite a bit Limited
3 | Moderately Limited
4 | Slightly Limited
5 | Not at all Limited
6 | Limited for other reasons or did not do the activity

Answer Key Q2 | Answer Value Q2 |
--- | --- |
1 | Every Morning
2 | 3 or more times per week but not every day
3 | 1-2 times per week
4 | Less than once a week
5 | Never over the past 2 weeks

Answer Key Q3-4 | Answer Value Q3-4 |
--- | --- |
1 | All of the time
2 | Severak times per day
3 | At least once a day
4 | 3 or more times per week but not every day
5 | 1-2 times per week
6 | Less than once a week
7 | Never over the past 2 weeks

Answer Key Q5 | Answer Value Q5 |
--- | --- |
1 | Every night
2 | 3 or more times per week but not every day
3 | 1-2 times per week
4 | Less than once a week
5 | Never over the past 2 weeks

Answer Key Q6 | Answer Value Q6 |
--- | --- |
1 | Every night
2 | 3 or more times per week but not every day
3 | 1-2 times per week
4 | Less than once a week
5 | Never over the past 2 weeks

Answer Key Q7 | Answer Value Q7 |
--- | --- |
1 | Not at all satisfied
2 | Mostly dissatisfied
3 | Somewhat satisfied
4 | Mostly satisfied
5 | Completed satisfied

Answer Key Q8 | Answer Value Q8 |
--- | --- |
1 | Severly Limited
2 | Limited Quite a bit 
3 | Moderately Limited
4 | Slightly Limited
5 | Did not limit at all
6 | Does not apply or did not do for other reasons

Example File:

```
1,134
2,2
3,3
4,5
5,5
6,4
7,2
8,511
```
## 5. Data Processing

WIP
###**Accel**
Use the loadAcc.m (uses processaccel.py) function to load it, then accFiltAmoss.m to bandpass filter and then convertAccToEpochs_oakley.m to convert to counts.


## 5. 3rd Party API
###**Epic on FHIR**
All EPIC FHIR EMR data collected are de-identified by filtering PHI before storing in the cloud. Documentation for data being collected can be found here:
https://open.epic.com/Interface/FHIR

###**Garmin**
All data available from the Health API is categorized as different types of summary data. Push integrations receive this data directly from the Push notification POST body, but Ping/Pull integrations must call the Health API with requests signed with the Consumer Key (representing the partner) and the UAT (representing the user) via OAuth. The summary data should be archived by the partner, as the Health API only keeps user data for fifteen days from the upload date.

Documentation for Garmin's summary data types are availble for registered users. To access this please contact the developers.

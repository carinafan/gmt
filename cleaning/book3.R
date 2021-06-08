#---- set up ----

# load data
df_raw = read_excel("../data/iago/event_clean.xlsx",
                    sheet = "Bookkeeping Task 3") %>% 
  as.data.frame()

# answer key

## task 1

task1_incorrect = c(
  "Receipt: Amount $100, billing: 01-Mar, payment: 21-Mar, filing: 30-Mar",
  "Receipt: Amount $100, billing: 13-Jun, payment: 13-Aug, filing: 14-Aug",
  "Receipt: Amount $100, billing: 01-Mar, payment: 21-Mar, filing: 30-Mar, duplicate",
  "Receipt: Amount $50, billing: 05-Jun, payment: 08-Jul, filing: 19-Jul, duplicate",
  "Receipt: Amount $230.07, billing: 09-Feb, payment: 10-Mar, filing: 12-Mar",
  "Receipt: Amount $100, billing: 03-Apr, payment: 01-May, filing: 30-Mar",
  "Receipt: Amount $250, billing: 08-Aug, payment: 10-Aug, filing: 15-Aug",
  "Receipt: Amount $50, billing: 05-Jun, payment: 08-Jul, filing: 19-Jul",
  "Receipt: Amount $50, billing: 26-May, payment: 03-Jun, filing: 10-Jun, duplicate",
  "Receipt: Amount $50, billing: 26-May, payment: 03-Jun, filing: 10-Jun",
  "Receipt: Amount $100, billing: 07-Sep, payment: 12-Oct, filing: 31-Oct",
  "Receipt: Amount $50, billing: 03-Apr, payment: 01-May, filing: 02-May, duplicate",
  "Receipt: Amount $100, billing: 13-Jul, payment: 13-Aug, filing: 14-Aug, duplicate",
  "Receipt: Amount $250, billing: 08-Aug, payment: 10-Aug, filing: 15-Aug, duplicate",
  "Receipt: Amount $121.09, billing: 02-Jan, payment: 02-Feb, filing: 04-Feb",
  "Receipt: Amount $100, billing: 27-Feb, payment: 25-Mar, filing: 01-Apr",
  "Receipt: Amount $100, billing: 07-Sep, payment: 12-Oct, filing: 12-Oct",
  "Receipt: Amount $121.09, billing: 02-Jan, payment: 02-Feb, filing: 04-Feb", 
  "Receipt: Amount $230.07, billing: 09-Feb, payment: 10-Mar, filing: 12-Mar, duplicate"
)

## task 2

task2_correct = c(
  "Receipt: Amount $50, billing: 01-Apr, payment: 29-Apr, filing: 01-May",
  "Receipt: Amount $200, billing: 04-May, payment: 28-May, filing: 31-May",
  "Receipt: Amount $100, billing: 08-May, payment: 30-May, filing: 10-Jun",
  "Receipt: Amount $211.86, billing: 20-Apr, payment: 30-Apr, filing: 05-May",
  "Receipt: Amount $164.4, billing: 16-May, payment: 20-May, filing: 10-Jun",
  "Receipt: Amount $200.1, billing: 04-Apr, payment: 29-Apr, filing: 12-May"
)

task2_incorrect = c(
  "Receipt: Amount $144.64, billing: 31-Mar, payment: 21-Feb, filing: 23-Feb",
  "Receipt: Amount $100, billing: 13-Jun, payment: 13-Aug, filing: 14-Aug",
  "Receipt: Amount $177.77, billing: 10-Jun, payment: 01-Jul, filing: 08-Jul",
  "Receipt: Amount $200.04, billing: 18-Feb, payment: 28-Feb, filing: 04-Mar",
  "Receipt: Amount $189.9, billing: 11-Oct, payment: 31-Oct, filing: 31-Oct",
  "Receipt: Amount $50, billing: 05-Jun, payment: 08-Jul, filing: 19-Jul",
  "Receipt: Amount $330.56, billing: 16-Nov, payment: 23-Nov, filing: 28-Nov",
  "Receipt: Amount $198.52, billing: 11-Jul, payment: 12-Aug, filing: 20-Aug",
  "Receipt: Amount $200.78, billing: 22-Mar, payment: 24-Mar, filing: 01-Apr",
  "Receipt: Amount $190.06, billing: 06-Jul, payment: 09-Jul, filing: 20-Jul",
  "Receipt: Amount $125.8, billing: 10-Jan, payment: 02-Feb, filing: 12-Feb",
  "Receipt: Amount $231.35, billing: 24-Aug, payment: 28-Aug, filing: 29-Aug",
  "Receipt: Amount $150.09, billing: 09-Sep, payment: 08-Oct, filing: 12-Oct",
  "Receipt: Amount $300.15, billing: 17-Nov, payment: 16-Dec, filing: 20-Dec",
  "Receipt: Amount $212.5, billing: 03-Dec, payment: 18-Dec, filing: 19-Dec",
  "Receipt: Amount $60, billing: 01-Feb, payment: 10-Feb, filing: 24-Feb",
  "Receipt: Amount $100, billing: 10-Nov, payment: 10-Dec, filing: 15-Dec",
  "Receipt: Amount $45, billing: 28-Sep, payment: 10-Oct, filing: 30-Oct",
  "Receipt: Amount $99.5, billing: 06-Feb, payment: 09-Feb, filing: 30-Feb",
  "Receipt: Amount $74.29, billing: 05-Mar, payment: 08-Mar, filing: 30-Mar",
  "Receipt: Amount $166.21, billing: 29-May, payment: 15-Jun, filing: 20-Jun",
  "Receipt: Amount $123.22, billing: 22-Nov, payment: 30-Dec, filing: 20-Jan",
  "Receipt: Amount $78.89, billing: 16-Jul, payment: 05-Aug, filing: 07-Aug",
  "Receipt: Amount $50, billing: 28-May, payment: 10-Jun, filing: 18-Jun"
)

## task 3

task3_correct = c(
  "Receipt: Amount $100, billing: 02-Apr, payment: 10-Apr, filing: 11-Apr",
  "Receipt: Amount $200, billing: 14-May, payment: 14-May, filing: 16-May",
  "Receipt: Amount $100, billing: 18-Jul, payment: 20-Jul, filing: 21-Jul",
  "Receipt: Amount $100, billing: 20-Jun, payment: 23-Jun, filing: 01-Jun",
  "Receipt: Amount $50, billing: 12-Jul, payment: 30-Jul, filing: 05-Aug"
)

task3_incorrect = c(
  "Receipt: Amount $230.6, billing: 30-Aug, payment: 12-Sep, filing: 30-Sep",
  "Receipt: Amount $100, billing: 02-Apr, payment: 10-Apr, filing: 11-Apr, duplicate",
  "Receipt: Amount $121.9, billing: 12-Aug, payment: 03-Nov, filing: 10-Nov",
  "Receipt: Amount $200, billing: 04-May, payment: 28-May, filing: 31-May, duplicate",
  "Receipt: Amount $200.01, billing: 02-Aug, payment: 01-Nov, filing: 02-Nov",
  "Receipt: Amount $200.9, billing: 02-Jan, payment: 10-Feb, filing: 11-Jan",
  "Receipt: Amount $100, billing: 20-Jun, payment: 23-Jun, filing: 01-Jun, duplicate",
  "Receipt: Amount $50, billing: 12-Jul, payment: 30-Jul, filing: 05-Aug, duplicate",
  "Receipt: Amount $123.08, billing: 10-Mar, payment: 21-Apr, filing: 23-Apr",
  "Receipt: Amount $131.21, billing: 10-Feb, payment: 30-Jun, filing: 01-Jun",
  "Receipt: Amount $121.11, billing: 05-Mar, payment: 10-Apr, filing: 30-Apr",
  "Receipt: Amount $300.15, billing: 17-Nov, payment: 16-Dec, filing: 20-Dec, duplicate"
)

## task 4

task4_correct = c(
  "Receipt: Amount $230.6, billing: 17-Feb, payment: 30-Mar, filing: 31-Mar",
  "Receipt: Amount $100, billing: 09-Apr, payment: 01-Apr, filing: 14-Mar",
  "Receipt: Amount $100, billing: 17-Mar, payment: 15-Apr, filing: 07-May",
  "Receipt: Amount $200, billing: 09-Feb, payment: 04-Aug, filing: 05-Aug",
  "Receipt: Amount $100, billing: 31-Apr, payment: 20-Nov, filing: 26-Nov",
  "Receipt: Amount $200, billing: 16-Feb, payment: 17-Mar, filing: 31-Mar", 
  "Receipt: Amount $200, billing: 07-Apr, payment: 31-Apr, filing: 04-Mar",
  "Receipt: Amount $200, billing: 05-Mar, payment: 18-Apr, filing: 25-Apr",
  "Receipt: Amount $200, billing: 12-Mar, payment: 02-Sep, filing: 20-Sep",
  "Receipt: Amount $100, billing: 04-Apr, payment: 05-May, filing: 06-May",
  "Receipt: Amount $100, billing: 01-May, payment: 19-May, filing: 29-May",
  "Receipt: Amount $200, billing: 02-Jan, payment: 01-Feb, filing: 10-Feb",
  "Receipt: Amount $200, billing: 17-May, payment: 10-Jul, filing: 15-Jul",
  "Receipt: Amount $100, billing: 24-Mar, payment: 16-Apr, filing: 31-Apr",
  "Receipt: Amount $100, billing: 27-Feb, payment: 25-Mar, filing: 01-Apr",
  "Receipt: Amount $200, billing: 21-Jan, payment: 21-Feb, filing: 25-Feb"
)

task4_incorrect = c(
  "Receipt: Amount $100, billing: 12-Jun, payment: 08-Aug, filing: 31-Aug",
  "Receipt: Amount $200, billing: 16-Nov, payment: 02-Dec, filing: 02-Dec"
)

## task 6

task6_correct = c(
  "Receipt: Amount $100, billing: 30-Dec, payment: 15-Jan, filing: 02-Oct",
  "Receipt: Amount $50, billing: 28-Mar, payment: 01-Apr, filing: 10-Apr",
  "Receipt: Amount $220.97, billing: 06-Jan, payment: 18-Jan, filing: 30-Jan", 
  "Receipt: Amount $200, billing: 03-Dec, payment: 15-Dec, filing: 20-Dec",
  "Receipt: Amount $198.17, billing: 10-Jan, payment: 22-Jan, filing: 31-Jan",
  "Receipt: Amount $50, billing: 18-Jun, payment: 09-Jul, filing: 29-Jul",
  "Receipt: Amount $100, billing: 20-Jul, payment: 25-Jul, filing: 01-Aug",
  "Receipt: Amount $200, billing: 02-Aug, payment: 02-Sep, filing: 03-Sep"
)

task6_incorrect = c(
  "Receipt: Amount $100, billing: 15-Apr, payment: 10-May, filing: 10-May",
  "Receipt: Amount $100, billing: 16-Nov, payment: 30-Nov, filing: 01-Dec",
  "Receipt: Amount $100, billing: 05-Feb, payment: 15-Feb, filing: 28-Feb, duplicate",
  "Receipt: Amount $100, billing: 15-Apr, payment: 10-May, filing: 10-May, duplicate",
  "Receipt: Amount $100, billing: 05-Feb, payment: 15-Feb, filing: 28-Feb",
  "Receipt: Amount $50, billing: 28-Mar, payment: 01-Apr, filing: 10-Apr, duplicate",
  "Receipt: Amount $300, billing: 17-Oct, payment: 02-Nov, filing: 16-Nov",
  "Receipt: Amount $200, billing: 20-May, payment: 20-Jun, filing: 21-Jun",
  "Receipt: Amount $113.06, billing: 02-Jan, payment: 13-Feb, filing: 21-Feb", 
  "Receipt: Amount $200, billing: 20-May, payment: 20-Jun, filing: 21-Jun, duplicate"
)

## task 7

task7_correct = c(
  "Receipt: Amount $50, billing: 02-Feb, payment: 25-Feb, filing: 28-Feb",
  "Receipt: Amount $100, billing: 05-Jul, payment: 16-Jul, filing: 20-Jul"
)

task7_incorrect = c(
  "Receipt: Amount $130.09, billing: 14-May, payment: 14-Jun, filing: 15-Jun, duplicate",
  "Receipt: Amount $50, billing: 26-Feb, payment: 12-Mar, filing: 13-Mar, duplicate",
  "Receipt: Amount $50, billing: 02-Feb, payment: 25-Feb, filing: 28-Feb, duplicate",
  "Receipt: Amount $102.05, billing: 02-Sep, payment: 01-Oct, filing: 04-Oct",
  "Receipt: Amount $50, billing: 26-Feb, payment: 12-Mar, filing: 13-Mar",
  "Receipt: Amount $102.05, billing: 02-Sep, payment: 01-Oct, filing: 04-Oct, duplicate",
  "Receipt: Amount $50, billing: 26-Feb, payment: 12-Mar, filing: 13-Mar, duplicate",
  "Receipt: Amount $50, billing: 02-Feb, payment: 25-Feb, filing: 28-Feb, duplicate",
  "Receipt: Amount $100, billing: 05-Dec, payment: 16-Dec, filing: 20-Dec, duplicate",
  "Receipt: Amount $100, billing: 05-Jul, payment: 16-Jul, filing: 20-Jul, duplicate",
  "Receipt: Amount $102.05, billing: 02-Sep, payment: 01-Oct, filing: 04-Oct, duplicate",
  "Receipt: Amount $100, billing: 05-Dec, payment: 16-Dec, filing: 20-Dec, duplicate",
  "Receipt: Amount $130.09, billing: 14-May, payment: 14-Jun, filing: 15-Jun",
  "Receipt: Amount $130.09, billing: 14-May, payment: 14-Jun, filing: 15-Jun, duplicate",
  "Receipt: Amount $102.05, billing: 02-Sep, payment: 01-Oct, filing: 04-Oct, duplicate",
  "Receipt: Amount $130.09, billing: 14-May, payment: 14-Jun, filing: 15-Jun, duplicate"
)

# set column names
names = c("user_id",
          "date",
          "order",
          "task",
          "switch_duration",
          "duration",
          "submitted",
          "method",
          "correct",
          "incorrect",
          "incorrect_date",
          "incorrect_account",
          "incorrect_duplicate"
          )

# find each task starts
started = which(df_raw$tag2 == "Started")

# number of starts
n = length(started)

# add 1 to end of start for subsetting last task start
started %<>% append(nrow(df_raw))

# set up empty dataframe
df = data.frame(matrix(data = NA, nrow = 0, ncol = length(names)))
names(df) = names
df$date %<>% ymd_hms()

#---- pull data ----

# for each task start...
for (i in 1:n) {
  
  # subset participant's rows
  range = (started[i]):(started[i+1]-1)
  raw_user_data = df_raw[range, ]
  
  # find task switches
  switches = 
    which(grepl("Selecting Task", raw_user_data$tag2)) %>%
    append(which(grepl("Revision Started", raw_user_data$tag2))) %>% 
    sort()
  
  if (identical(switches, integer(0))) { # if there are only Game Ended rows
    next 
  }
  
  if (grepl("Game Ended", raw_user_data$tag2[nrow(raw_user_data)])) {
    switches %<>% 
      append(head(which(raw_user_data$tag2 == "Game Ended"), 1))
  } else {
    switches %<>%
      append(nrow(raw_user_data) + 1)
  }
  
  # pull user ID
  temp_id = raw_user_data$user_id[1]
  
  # set up participant dataframe
  temp_df = matrix(data = NA, 
                   nrow = length(switches) - 1, 
                   ncol = length(names)) %>%
    data.frame()
  
  names(temp_df) = names
  
  temp_df$user_id = raw_user_data$user_id[1]
  
  temp_df$date %<>% ymd_hms()
  
  temp_df$order = seq(1, (length(switches) - 1))
  
  temp_df$correct = 0
  temp_df$incorrect = 0
  temp_df$incorrect_date = 0
  temp_df$incorrect_account = 0
  temp_df$incorrect_duplicate = 0
 
  # fill in task data
  for (s in 1:(length(switches) - 1)) {
    
    # subset task rows
    task_range = switches[s]:(switches[s+1]-1)
    raw_task_data = raw_user_data[task_range, ]
    
    # date
    temp_date = raw_task_data$created_at[1]
    temp_df$date[s] = temp_date
    
    # task
    temp_task = raw_task_data$tag2[1]
    
    if (grepl("Selecting Task", temp_task)) {
      
      temp_task %<>% strsplit(" ")
      temp_task = temp_task[[1]][3] 
        
    } 
    
    if (grepl("Revision Started", temp_task)) {
      
      temp_task %<>% strsplit(" ")
      temp_task = temp_task[[1]][2]
      
    }
    
    temp_df$task[s] = temp_task

    # switch duration
    temp_switch = raw_user_data$created_at[(switches[s]-1)] %>% 
      interval(raw_task_data$created_at[1]) %>% 
      time_length("seconds")
    
    temp_df$switch_duration[s] = temp_switch
    
    # duration
    temp_duration = raw_task_data$created_at[1] %>% 
      interval(raw_task_data$created_at[nrow(raw_task_data)]) %>% 
      time_length("seconds")
    
    temp_df$duration[s] = temp_duration
    
    # submitted
    if (!grepl("Submitted", raw_task_data$tag2) %>% any()) {
      temp_df$submitted[s] = "no"
    } else {
      if (tail(raw_task_data$tag3[which(grepl("Submitted", raw_task_data$tag2))], 1) ==
          "Correct: true") {
        temp_df$submitted[s] = "correct"
      }
      if (tail(raw_task_data$tag3[which(grepl("Submitted", raw_task_data$tag2))], 1) ==
          "Correct: false") {
        temp_df$submitted[s] = "incorrect"
      }
    } 
      
    # receipt scoring
    temp_receipt_df = raw_task_data %>% 
      filter(grepl("Receipt", tag2)) %>% 
      select(tag2) %>% 
      filter(!grepl("Submitted", tag2))
    
    temp_receipt_list = vector(mode = "character")
    
    if (nrow(temp_receipt_df > 0)) {
      
      for (r in 1:nrow(temp_receipt_df)) {
        
        ## split up receipt info
        
        temp_receipt = temp_receipt_df$tag2[r] %>%
          str_split(", duplicate: ")
        
        temp_receipt_df$receipt[r] = temp_receipt[[1]][1]
        
        temp_receipt = temp_receipt[[1]][2] %>%
          strsplit(", ")
        
        temp_receipt_df$duplicate[r] = temp_receipt[[1]][1]
        
        temp_receipt = temp_receipt[[1]][2] %>%
          strsplit(" ")
        
        temp_receipt_df$account[r] = temp_receipt[[1]][3]
        
        temp_receipt_df$select[r] = temp_receipt[[1]][4]
        
        ## pull receipts into list
        
        if (temp_receipt_df$select[r] == "Selected") {
          
          temp_receipt = temp_receipt_df$receipt[r]
          
          if (temp_receipt_df$duplicate[r] == "true") {
            temp_receipt %<>% paste0(", duplicate")
          }
          
          temp_receipt_list %<>% append(temp_receipt)
          
        }
        
        if (temp_receipt_df$select[r] == "Deselected") {
          
          temp_deselect = which(temp_receipt_list == temp_receipt_df$receipt[r]) %>% 
            head(1)
          
          temp_receipt_list = temp_receipt_list[-temp_deselect]
          
        }
        
      }
      
      if (length(temp_receipt_list > 0)) {

        ## task 1

        if (temp_task == "1") {

          # method
          temp_method = raw_task_data %>%
            filter(grepl("Sum Selected", tag2)|
                     grepl("Average Selected", tag2)) %>%
            tail(1) %>%
            select(tag2)

          if (grepl("Average", temp_method)) {
            temp_df$method[s] = "incorrect"
          }

          if (grepl("Sum", temp_method)) {
            temp_df$method[s] = "incorrect"
          }

          # receipts
          for (c in 1:length(temp_receipt_list)) {

            temp_receipt = temp_receipt_list[c]

              # incorrect
              temp_df$incorrect[s] = temp_df$incorrect[s] + 1

              # incorrect date
              temp_df$incorrect_date[s] = temp_df$incorrect_date[s] + 1

              # incorrect account
              if (! temp_receipt %in% task1_incorrect) {
                temp_df$incorrect_account[s] = temp_df$incorrect_account[s] + 1
              }

              # incorrect duplicate
              if (grepl("duplicate", temp_receipt)) {
                temp_df$incorrect_duplicate[s] = temp_df$incorrect_duplicate[s] + 1
              }

            }

          }


        ## task 2

        if (temp_task == "2") {

          # method
          temp_method = raw_task_data %>%
            filter(grepl("Sum Selected", tag2)|
                     grepl("Average Selected", tag2)) %>%
            tail(1) %>%
            select(tag2)

          if (grepl("Average", temp_method)) {
            temp_df$method[s] = "incorrect"
          }

          if (grepl("Sum", temp_method)) {
            temp_df$method[s] = "correct"
          }

          # receipts
          for (c in 1:length(temp_receipt_list)) {

            temp_receipt = temp_receipt_list[c]

            # correct
            if (temp_receipt %in% task2_correct) {
              temp_df$correct[s] = temp_df$correct[s] + 1
            } else {
              # incorrect
              temp_df$incorrect[s] = temp_df$incorrect[s] + 1

              # incorrect date
              if (grepl("Apr", temp_receipt) |
                  grepl("May", temp_receipt)) {
                temp_df$incorrect_date[s] = temp_df$incorrect_date[s] + 1
              }

              # incorrect account
              if (! temp_receipt %in% task2_correct &
                  ! temp_receipt %in% task2_incorrect) {
                temp_df$incorrect_account[s] = temp_df$incorrect_account[s] + 1
              }

              # incorrect duplicate
              if (grepl("duplicate", temp_receipt)) {
                temp_df$incorrect_duplicate[s] = temp_df$incorrect_duplicate[s] + 1
              }

            }

          }

        }

        ## task 3

        if (temp_task == "3") {

          # method
          temp_method = raw_task_data %>%
            filter(grepl("Sum Selected", tag2)|
                     grepl("Average Selected", tag2)) %>%
            tail(1) %>%
            select(tag2)

          if (grepl("Average", temp_method)) {
            temp_df$method[s] = "incorrect"
          }

          if (grepl("Sum", temp_method)) {
            temp_df$method[s] = "correct"
          }

          # receipts
          for (c in 1:length(temp_receipt_list)) {

            temp_receipt = temp_receipt_list[c]

            # correct
            if (temp_receipt %in% task3_correct) {
              temp_df$correct[s] = temp_df$correct[s] + 1
            } else {
              # incorrect
              temp_df$incorrect[s] = temp_df$incorrect[s] + 1

              # incorrect date
              if (grepl("Apr", temp_receipt) |
                  grepl("May", temp_receipt) |
                  grepl("Jun", temp_receipt) |
                  grepl("Jul", temp_receipt)) {
                temp_df$incorrect_date[s] = temp_df$incorrect_date[s] + 1
              }

              # incorrect account
              if (! temp_receipt %in% task3_correct &
                  ! temp_receipt %in% task3_incorrect) {
                temp_df$incorrect_account[s] = temp_df$incorrect_account[s] + 1
              }

              # incorrect duplicate
              if (grepl("duplicate", temp_receipt)) {
                temp_df$incorrect_duplicate[s] = temp_df$incorrect_duplicate[s] + 1
              }

            }

          }

        }
      

        ## task 4

        if (temp_task == "4") {

          # method
          temp_method = raw_task_data %>%
            filter(grepl("Sum Selected", tag2)|
                     grepl("Average Selected", tag2)) %>%
            tail(1) %>%
            select(tag2)

          if (grepl("Average", temp_method)) {
            temp_df$method[s] = "incorrect"
          }

          if (grepl("Sum", temp_method)) {
            temp_df$method[s] = "correct"
          }

          # receipts
          for (c in 1:length(temp_receipt_list)) {

            temp_receipt = temp_receipt_list[c]

            # correct
            if (temp_receipt %in% task4_correct) {
              temp_df$correct[s] = temp_df$correct[s] + 1
            } else {
              # incorrect
              temp_df$incorrect[s] = temp_df$incorrect[s] + 1

              # incorrect date
              if (grepl("Jan", temp_receipt) |
                  grepl("Feb", temp_receipt) |
                  grepl("Mar", temp_receipt) |
                  grepl("Apr", temp_receipt) |
                  grepl("May", temp_receipt) |
                  grepl("June", temp_receipt)) {
                temp_df$incorrect_date[s] = temp_df$incorrect_date[s] + 1
              }

              # incorrect account
              if (! temp_receipt %in% task4_correct &
                  ! temp_receipt %in% task4_incorrect) {
                temp_df$incorrect_account[s] = temp_df$incorrect_account[s] + 1
              }

              # incorrect duplicate
              if (grepl("duplicate", temp_receipt)) {
                temp_df$incorrect_duplicate[s] = temp_df$incorrect_duplicate[s] + 1
              }

            }

          }

        }

        ## task 5

        if (temp_task == "5") {

          # method
          temp_method = raw_task_data %>%
            filter(grepl("Sum Selected", tag2)|
                     grepl("Average Selected", tag2)) %>%
            tail(1) %>%
            select(tag2)

          if (grepl("Average", temp_method)) {
            temp_df$method[s] = "incorrect"
          }

          if (grepl("Sum", temp_method)) {
            temp_df$method[s] = "correct"
          }

          # receipts
          for (c in 1:length(temp_receipt_list)) {

            temp_receipt = temp_receipt_list[c]

              # incorrect
              temp_df$incorrect[s] = temp_df$incorrect[s] + 1

              # incorrect date
              if (grepl("Jun", temp_receipt) |
                  grepl("Jul", temp_receipt)) {
                temp_df$incorrect_date[s] = temp_df$incorrect_date[s] + 1
              }

              # incorrect account
              temp_df$incorrect_account[s] = temp_df$incorrect_account[s] + 1

              # incorrect duplicate
              if (grepl("duplicate", temp_receipt)) {
                temp_df$incorrect_duplicate[s] = temp_df$incorrect_duplicate[s] + 1
              }

            }

          }

        ## task 6

        if (temp_task == "6") {

          # method
          temp_method = raw_task_data %>%
            filter(grepl("Sum Selected", tag2)|
                     grepl("Average Selected", tag2)) %>%
            tail(1) %>%
            select(tag2)

          if (grepl("Average", temp_method)) {
            temp_df$method[s] = "correct"
          }

          if (grepl("Sum", temp_method)) {
            temp_df$method[s] = "incorrect"
          }

          # receipts
          for (c in 1:length(temp_receipt_list)) {

            temp_receipt = temp_receipt_list[c]

              # incorrect
              temp_df$incorrect[s] = temp_df$incorrect[s] + 1

              # incorrect date
              if (grepl("Jan", temp_receipt) |
                  grepl("Apr", temp_receipt) |
                  grepl("Jul", temp_receipt) |
                  grepl("Sep", temp_receipt) |
                  grepl("Dec", temp_receipt)) {
                temp_df$incorrect_date[s] = temp_df$incorrect_date[s] + 1
              }

              # incorrect account
              if (! temp_receipt %in% task6_correct &
                  ! temp_receipt %in% task6_incorrect) {
                temp_df$incorrect_account[s] = temp_df$incorrect_account[s] + 1
              }

              # incorrect duplicate
              if (grepl("duplicate", temp_receipt)) {
                temp_df$incorrect_duplicate[s] = temp_df$incorrect_duplicate[s] + 1
              }

            }

        }
      
      ## task 7
      
      if (temp_task == "7") {
        
        # method
        temp_method = raw_task_data %>%
          filter(grepl("Sum Selected", tag2)|
                   grepl("Average Selected", tag2)) %>%
          tail(1) %>%
          select(tag2)
        
        if (grepl("Average", temp_method)) {
          temp_df$method[s] = "incorrect"
        }
        
        if (grepl("Sum", temp_method)) {
          temp_df$method[s] = "correct"
        }
        
        # receipts
        for (c in 1:length(temp_receipt_list)) {
          
          temp_receipt = temp_receipt_list[c]
          
          # incorrect
          temp_df$incorrect[s] = temp_df$incorrect[s] + 1
          
          # incorrect date
          if (grepl("Feb", temp_receipt) |
              grepl("Jul", temp_receipt)) {
            temp_df$incorrect_date[s] = temp_df$incorrect_date[s] + 1
          }
          
          # incorrect account
          if (! temp_receipt %in% task7_correct &
              ! temp_receipt %in% task7_incorrect) {
            temp_df$incorrect_account[s] = temp_df$incorrect_account[s] + 1
          }
          
          # incorrect duplicate
          if (grepl("duplicate", temp_receipt)) {
            temp_df$incorrect_duplicate[s] = temp_df$incorrect_duplicate[s] + 1
          }
          
        }
        
      }

      }
      
    }
    
    ## task 5
    
    if (identical(temp_receipt_list, character(0)) &
        temp_task == "5") {

      if (grepl("Selecting Account 'No Account' for Task 5", raw_task_data$tag2) %>% any()) {
        temp_df$submitted[s] = "correct"
      }

    }
    
  }
  
  # append participant dataframe to overall dataframe
  df %<>% rbind(temp_df)
  
  # remove temp stuff
  rm( list = ls()[ ( grepl("temp", ls()) ) ] ) 
  
}

#---- data dictionary ----

# export column names
dict = names(df) %>%
  as.data.frame(stringsAsFactors = FALSE)
names(dict) = "column_label"

# add columns to describe the variables in each column
dict$description = NA
dict$type = NA
dict$value_range = NA

# fill in dictionary
for (d in 1:nrow(dict)) {
  
  switch(dict$column_label[d],
         
         "user_id" = {
           dict$description[d] = "user ID"
           dict$type[d] = "ID number"
           dict$value_range[d] = "NA"
         },
         
         "date" = {
           dict$description[d] = "date (yyyy-mm-dd hh-mm-ss UTC)"
           dict$type[d] = "date"
           dict$value_range[d] = "NA"
         },
         
         "order" = {
           dict$description[d] = "order in which each task was selected"
           dict$type[d] = "integer"
           dict$value_range[d] = "any integer greater than 0"
         },
         
         "task" = {
           dict$description[d] = "number of task selected"
           dict$type[d] = "integer"
           dict$value_range[d] = "1 to 3"
         },
         
         "switch_duration" = {
           dict$description[d] = "duration between end of last task and start if present task (or in the case of the first task, the beginning of the Bookkeeping Task and the start of the first task within that) in seconds"
           dict$type[d] = "integer"
           dict$value_range[d] = "greater than 0"
         },
         
         "duration" = {
           dict$description[d] = "task duration in seconds"
           dict$type[d] = "integer"
           dict$value_range[d] = "greater than 0"
         },
         
         "submitted" = {
           dict$description[d] = "whether task was submitted or not"
           dict$type[d] = "factor"
           dict$value_range[d] = "no (not submitted), correct (submitted and correct), or incorrect (submitted and incorrect)"
         },
         
         "method" = {
           dict$description[d] = "whether method selected to tally receipts (average or sum) was correcft or not"
           dict$type[d] = "factor"
           dict$value_range[d] = "correct or incorrect"
         },
         
         "correct" = {
           dict$description[d] = "number of correct receipts selected"
           dict$type[d] = "integer"
           dict$value_range[d] = "0 or greater"
         },
         
         "incorrect" = {
           dict$description[d] = "total number of incorrect receipts selected"
           dict$type[d] = "integer"
           dict$value_range[d] = "0 or greater"
         },
         
         "incorrect_date" = {
           dict$description[d] = "number of incorrect receipts selected that had some date overlap with correct receipts"
           dict$type[d] = "integer"
           dict$value_range[d] = "0 or greater"
         },
         
         "incorrect_account" = {
           dict$description[d] = "number of receipts selected from incorrect account"
           dict$type[d] = "integer"
           dict$value_range[d] = "0 or greater"
         },
         
         "incorrect_duplicate" = {
           dict$description[d] = "number of duplicate receipts selected"
           dict$type[d] = "integer"
           dict$value_range[d] = "0 or greater"
         }
         
         )
}

#---- clean up ----

df_book3 = df
dict_book3 = dict

rm(list = ls()[!(ls() %in% df_to_keep)])

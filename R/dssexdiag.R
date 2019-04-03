# dssexdiag.R
# Created date: 2019/4/3
# Author: mariko ohtsuka
# library, function section ------
# install.packages("here")
library(here)
library(stringr)
source(here("R", "common_function.R"))
# Constant section ------
ConstAssign("kOrganization", "NHOH")
ConstAssign("kOrganizationRegistration", "NHOH_registration")
ConstAssign("kOrganizationReport", "NHOH_report")
ConstAssign("kTrialRegistration", "ITP_15_registration")
ConstAssign("kKeyCol", "登録コード")
# Setting of input/output path
input_path <- here("R", "input")
# If the output folder does not exist, create it
output_path <- here("R", "output")
if (file.exists(output_path) == F) {
  dir.create(output_path)
}
# read rawdata
csv_list <- list.files(input_path)
for (i in 1:length(csv_list)) {
  if (str_sub(csv_list[i], -4) == ".csv") {
    temp_objectname <- ConvertCsvName(csv_list[i])
    temp_csv <- read.csv(str_c(input_path, "/", csv_list[i]), as.is=T, fileEncoding="cp932",
                         stringsAsFactors=F, na.strings="")
    assign(temp_objectname, temp_csv)
  }
}
# sort by 登録コード
assign(kOrganizationRegistration, get(kOrganizationRegistration)[order(get(kOrganizationRegistration)[ ,kKeyCol]),])
assign(kTrialRegistration, get(kTrialRegistration)[order(get(kTrialRegistration)[ ,kKeyCol]),])
assign(kOrganizationReport, get(kOrganizationReport)[order(get(kOrganizationReport)[ ,kKeyCol]),])
# merge by 登録コード
temp_dssex <- merge(get(kTrialRegistration), get(kOrganizationRegistration), by=kKeyCol)
dssex <- temp_dssex[ ,c("登録コード", "症例登録番号.x", "性別")]
temp_dssexdiag <- merge(dssex, get(kOrganizationReport), by=kKeyCol, all.x=T)
dssexdiag <- temp_dssexdiag[ ,c("症例登録番号.x", "性別", "診断年月日")]
colnames(dssexdiag) <- c("subjid", "sex", "dianday")
kakunin <- temp_dssexdiag[ ,c("登録コード", "症例登録番号.x", "性別", "診断年月日")]
# output csv
write.csv(kakunin, here("R", "output", "kakunin.csv"), row.names=F, fileEncoding = "cp932", na="")
OutputDF("dssexdiag", here("R", "output", ""), here("R", "output", ""))

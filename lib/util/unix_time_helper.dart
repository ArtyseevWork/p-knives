String convertUnixTimeToDateTime(int unixTime) {
  if (unixTime < 10000000000) {
    return "-";
  }
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime).toLocal();
  String formattedDateTime = "${dateTime.day.toString().padLeft(2, '0')}."
      "${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} "
      "${dateTime.hour.toString().padLeft(2, '0')}:"
      "${dateTime.minute.toString().padLeft(2, '0')}";
  return formattedDateTime;
}

int getTimestamp(){
  DateTime now = DateTime.now();
  int timestamp = now.millisecondsSinceEpoch;
  return timestamp;
}
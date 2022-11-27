export default (error, caller) => {
  if (error.response) {
    if ([400, 401, 404].includes(error.response.status)) {
      caller.$toast.error(error.response.data.message);
    } else if (error.response.status == 422) {
      caller.$toast.error(Object.values(error.response.data.error)[0][0]);
    } else {
      console.log(error);
      caller.$toast.error("An error has occcured! We have been notified!");
    }

  } else {
    console.log(error);
    caller.$toast.error("An error has occcured! We have been notified!");
  }

};

export default (error, caller) => {
  if (error.response.status == 400) {
    caller.$toast.error(error.response.data.message);
  } else if (error.response.status == 422) {
    caller.$toast.error(Object.values(error.response.data.error)[0][0]);
  }
};

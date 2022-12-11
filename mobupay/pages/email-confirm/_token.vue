<template>
  <v-row class="content px-md-5">
    <v-col class="pa-md-0" cols="12" sm="6">
      {{ message }}
    </v-col>
  </v-row>
</template>

<script>
import errorCatch from "../../functions/catchError";

export default {
  name: "email-confirm-token",
  data: () => ({
    token: "",
    message: "",
  }),
  methods: {
    async verify_email() {
      try {
        const response = await this.$axios.post("/verify-whatsapp-email", {
          token: this.token,
        });
        let data = response.data;
        if (data.confirmed) {
          this.message = "Your email has been verified successfully";
        } else {
          this.message = "Unable to verify email";
        }
      } catch (error) {
        errorCatch(error, this);
      }
    },
  },
  mounted() {
    this.token = this.$route.params.token;
    this.verify_email();
  },
};
</script>

<style lang="scss" scoped>
</style>

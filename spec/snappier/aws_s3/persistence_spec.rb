# frozen_string_literal: true

require "spec_helper"

RSpec.describe Snappier::AwsS3::Persistence do
  before do
    bucket_name = ENV.fetch("SNAPPIER_BUCKET_NAME")
    region = ENV.fetch("SNAPPIER_AWS_REGION")
    @instance = described_class.new(
      bucket_name: bucket_name,
      region: region,
    )
  end

  context "when no data has been persisted" do
    it "yields nothing" do
      snaps = []

      @instance.each(type: "A::B::C", id: "123456") do |snap|
        snaps << snap
      end

      expect(snaps).to be_empty
    end
  end

  context "when some data has been persisted" do
    it "yields timestamp and content for each persisted file" do
      @instance.persist(
        type: "A::B::C",
        id: "12345",
        at: "2000000001000",
        args: {
          "content" => "content1"
        },
      )

      @instance.persist(
        type: "A::B::C",
        id: "12345",
        at: "2000000000000",
        args: {
          "content" => "content2"
        },
      )

      @instance.persist(
        type: "A:B::C",
        id: "12345",
        at: "2000000002000",
        args: {
          "content" => "content3"
        },
      )

      snaps = []

      @instance.each(type: "A::B::C", id: "12345") do |snap|
        snaps << snap
      end

      expect(snaps).to(
        eq(
          [
            {
              at: Time.iso8601("2033-05-18T13:33:20+10:00"),
              content: { "content" => "content2" }
            },
            {
              at: Time.iso8601("2033-05-18T13:33:21+10:00"),
              content: { "content" => "content1" }
            },
            {
              at: Time.iso8601("2033-05-18T13:33:22+10:00"),
              content: { "content" => "content3" }
            }
          ],
        ),
      )
    end
  end
end

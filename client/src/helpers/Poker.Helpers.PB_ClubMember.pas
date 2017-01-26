unit Poker.Helpers.PB_ClubMember;

interface

uses
  Poker.Protobufs.Objects.ClubMember;

type
  TPB_ClubMemberHelper = class helper for TPB_ClubMember
    function StatusAsString: String;
  end;

implementation

{ TPB_ClubMemberHelper }

function TPB_ClubMemberHelper.StatusAsString: String;
begin
  case Status of
    msActive: result := 'Active';
    msSuspended: result := 'Suspended';
    msPending: result := 'Pending';
  else
    result := 'Unknown';
  end;
end;

end.

#source /remote/gemini1/user/rdevmore/for_rahul_abs_routing/.titanprocs.tcl

# From /remote/us01home36/sabbas/.titanprocs.tcl
proc bin { ids } {
  foreach id $ids {
    win add object to bin [win get window active] $id
  }
}

# clean the selection bin
proc clear_bin {} {
  win clear bin [win get window active]
}


proc ::add_my_custom_bonds {molcellid} {
  # clean-up all custom bonds (in case you're rerunning multiple times
  # NOTE: comment this out if adding custom bonds from the ALX GUI!
  alx delete constraint $molcellid all

alx add constraint symmetry $molcellid { 702 704 705 706 708 709 710 711 712 713 714 716 717 718 719 721 722 723 724 725 726 727 728 730 731 732 733 734 735 736 737 738 739 740 741 742 743 748 749 750 751 752 753 } -dir x -soft -force 1000.000 -note autoSymWireV_M2_5.212-5.215
}

# pairs from bond: 4890
set list1 {219 231 190 209 202 240 210 239 198 211 193 201 212 200 238 213 205 223 224 197 204 206} 
set list2 {196 199 190 218 194 226 220 241 227 216 192 225 215 229 236 214 207 221 223 228 230 206}

set pairs {}
proc m2o m { alx::molcell::get_objid_of_mid $m }
proc o2m o { alx::molcell::get_mid_of_objid $o }
proc get_pairs {} {
    foreach o1 $list1 o2 $list2 { lappend pairs [m2o "$o1 $o2"] }
}

# show the next pair:
proc show_next_pair {} { clear_bin; variable i; variable pairs; puts "i=[incr i] pair=[set pair [lindex $pairs $i]]"; bin $pair }
ediDefineKey 5 show_next_pair
set i -1

proc show_objs {args} {
    clear_bin
    bin $args
}

# objids:
set all_pairs {{731 708} {743 711} {702 702} {721 730} {714 706} {752 738} {722 732} {751 753} {710 739} {723 728} {705 704} {713 737} {724 727} {712 741} {750 748} {725 726} {717 719} {735 733} {736 735} {709 740} {716 742} {718 718}}
set all_objs {}
foreach p $all_pairs {
    lappend all_objs [lindex $p 0] [lindex $p 1]
}
lsort -unique $all_objs

set bad_pair_ids {0 1 4 5 17 18} ; 
set bad_pair_objs {{731 708} {743 711} {714 706} {752 738} {735 733} {736 735}}
set mis_aligned_id 19 ; # objs: 709 vs 740
set mis_aligned_objs {709 740}
return

4890 1 Symmetry-Soft 0 {219 231 190 209 202 240 210 239 198 211 193 201 212 200 238 213 205 223 224 197 204 206} {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0} {196 199 190 218 194 226 220 241 227 216 192 225 215 229 236 214 207 221 223 228 230 206} {1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1} {} cb-symmetry 1000
4891 1 Symmetry-Soft 0 {219 231 190 209 202 240 210 239 198 211 193 201 212 200 238 213 205 223 224 197 204 206} {1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1} {196 199 190 218 194 226 220 241 227 216 192 225 215 229 236 214 207 221 223 228 230 206} {0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0} {} cb-symmetry 1000

# kit6_orig_alx_resfix_tst@alxh_tsmc45lp_ipdk/AOP_AMP_CORE_tc.molcell/layout_original
# Device Symmetry Bonds
alx add constraint symmetry 28 { 533 534 540 541 539 } -dir x -note autoSymDeviceVM_5.212-5.215

# Route Symmetry Bonds
alx add constraint symmetry 28 { 593 594 595 596 597 598 599 600 601 602 603 605 606 607 608 609 610 611 612 613 614 615 616 617 618 619 620 621 622 623 624 625 626 627 628 629 630 631 632 633 634 635 636 639 640 641 642 643 644 645 646 647 648 649 650 651 652 653 655 656 657 658 659 660 661 662 663 664 665 666 667 668 669 670 671 672 673 674 675 676 677 678 679 680 682 683 684 685 686 689 690 692 693 694 696 697 } -dir x -soft -force 1000.000 -note autoSymWireV_M1_5.212-5.215
alx add constraint alignment 28 { 690 693 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:5.375_R:10.190
alx add constraint alignment 28 { 594 595 596 597 611 612 613 650 651 653 680 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:5.910_R:9.660
alx add constraint alignment 28 { 674 678 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:7.785_R:9.880
alx add constraint alignment 28 { 649 652 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:9.770_R:9.880
alx add constraint alignment 28 { 682 685 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:11.785_R:15.290
alx add constraint alignment 28 { 614 615 616 617 618 619 620 621 622 623 624 625 626 627 628 629 630 631 632 633 634 635 636 642 643 644 645 646 656 657 658 659 660 661 662 663 664 665 667 669 670 671 675 677 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:12.310_R:14.760
alx add constraint alignment 28 { 639 655 640 641 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:14.885_R:14.995
alx add constraint alignment 28 { 606 676 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:15.430_R:15.545
alx add constraint alignment 28 { 686 689 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:17.180_R:20.565
alx add constraint alignment 28 { 601 603 605 607 608 609 610 666 668 694 696 697 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:17.715_R:20.035
alx add constraint alignment 28 { 672 679 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M1_5.212-5.215_L:18.875_R:20.255
alx add constraint alignment 28 { 594 647 } -dir y -soft -force 10000.000 -line left -note autoSymWireV_M1_5.212-5.215_L:5.910
alx add constraint alignment 28 { 682 683 } -dir y -soft -force 10000.000 -line left -note autoSymWireV_M1_5.212-5.215_L:11.785
alx add constraint alignment 28 { 673 684 } -dir y -soft -force 10000.000 -line left -note autoSymWireV_M1_5.212-5.215_L:15.180
alx add constraint alignment 28 { 649 674 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M1_5.212-5.215_R:9.880
alx add constraint alignment 28 { 647 648 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M1_5.212-5.215_R:9.895
alx add constraint alignment 28 { 690 692 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M1_5.212-5.215_R:10.190
alx add constraint alignment 28 { 599 600 639 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M1_5.212-5.215_R:14.995
alx add constraint alignment 28 { 682 684 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M1_5.212-5.215_R:15.290
alx add constraint alignment 28 { 602 606 673 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M1_5.212-5.215_R:15.545
alx add constraint symmetry 28 { 702 704 705 706 708 709 710 711 712 713 714 716 717 718 719 721 722 723 724 725 726 727 728 730 731 732 733 734 735 736 737 738 739 740 741 742 743 748 749 750 751 752 753 } -dir x -soft -force 1000.000 -note autoSymWireV_M2_5.212-5.215
alx add constraint alignment 28 { 751 753 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M2_5.212-5.215_L:-0.205_R:10.080
alx add constraint alignment 28 { 716 742 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M2_5.212-5.215_L:5.910_R:11.505
alx add constraint alignment 28 { 711 731 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M2_5.212-5.215_L:9.965_R:10.080
alx add constraint alignment 28 { 708 743 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M2_5.212-5.215_L:9.965_R:15.000
alx add constraint alignment 28 { 706 752 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M2_5.212-5.215_L:11.275_R:11.505
alx add constraint alignment 28 { 709 710 712 713 714 737 738 739 741 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M2_5.212-5.215_L:11.275_R:14.760
alx add constraint alignment 28 { 721 722 723 724 725 726 727 728 730 732 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M2_5.212-5.215_L:12.310_R:15.660
alx add constraint alignment 28 { 704 705 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M2_5.212-5.215_L:14.885_R:15.000
alx add constraint alignment 28 { 733 736 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M2_5.212-5.215_L:16.940_R:20.035
alx add constraint alignment 28 { 748 749 750 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M2_5.212-5.215_L:17.715_R:24.050
alx add constraint alignment 28 { 708 711 } -dir y -soft -force 10000.000 -line left -note autoSymWireV_M2_5.212-5.215_L:9.965
alx add constraint alignment 28 { 706 709 } -dir y -soft -force 10000.000 -line left -note autoSymWireV_M2_5.212-5.215_L:11.275
alx add constraint alignment 28 { 721 734 } -dir y -soft -force 10000.000 -line left -note autoSymWireV_M2_5.212-5.215_L:12.310
alx add constraint alignment 28 { 733 735 } -dir y -soft -force 10000.000 -line left -note autoSymWireV_M2_5.212-5.215_L:16.940
alx add constraint alignment 28 { 717 718 719 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M2_5.212-5.215_R:9.660
alx add constraint alignment 28 { 711 751 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M2_5.212-5.215_R:10.080
alx add constraint alignment 28 { 706 716 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M2_5.212-5.215_R:11.505
alx add constraint alignment 28 { 709 740 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M2_5.212-5.215_R:14.760
alx add constraint alignment 28 { 704 708 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M2_5.212-5.215_R:15.000
alx add constraint alignment 28 { 702 721 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M2_5.212-5.215_R:15.660
alx add constraint alignment 28 { 734 735 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M2_5.212-5.215_R:17.055
alx add constraint symmetry 28 { 758 759 762 763 } -dir x -soft -force 1000.000 -note autoSymWireV_M3_5.212-5.215
alx add constraint alignment 28 { 762 763 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M3_5.212-5.215_L:14.745_R:15.000
alx add constraint alignment 28 { 758 759 } -dir y -soft -force 10000.000 -line both -note autoSymWireV_M3_5.212-5.215_L:14.885_R:15.000
alx add constraint alignment 28 { 758 762 } -dir y -soft -force 10000.000 -line right -note autoSymWireV_M3_5.212-5.215_R:15.000
